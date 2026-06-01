#!/usr/bin/env python
# -*- coding: utf-8 -*-
import os
import shutil
import sys
import ConfigParser
import json
import subprocess
import argparse
import time
from datetime import datetime, timedelta
from threading import Thread
import logging
import urllib2
import yaml
import re
import pprint
import copy
import itertools
import inquirer
import pretty_format as fmt
from ec2 import Ec2, LoadBlancing
import logger_config
import coloredlogs
import boto3
from runner.ansible_runner import Runner

reload(sys)
sys.setdefaultencoding('utf-8')
logging.basicConfig()
logger = logging.getLogger(__file__)

AWS_REGION = os.environ.get('AWS_REGION')
CUR_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__)))


class Deployer:

    def __init__(self, aws_region, action, params, adjust=False, skip_exist_service_for_start=False, disable_update_code=False):
        """Deploy java web service to AWS ec2 instances

        ``ajust``为true，action=start时生效，调整服务到适合其运行的ec2实例上
        在java程序运行所需的cpu和memory产出变化时进行调整，cpu和memory的使用量变大或者变小时，将其调整到适合其运行的ec2实例上
        调整规则为：cpu和memory的配置变化时，检查服务运行的ec2实例，根据配置所需cpu和memory额度，计算出当前ec2里面运行的所有服务需要的cpu和memory额度总和
            1. cpu或者memory额度大于ec2提供的最大额度，按一定规则选择出满足其运行需求的ec2实例，将服务迁移到改实例上
            2. cpu或者memory额度小于ec2提供的最大额度，查找是否存在更适合其运行的ec2实例，存在则迁移服务
        选择服务的规则为：按memory降序排序依次选择符合的实例
        服务迁移顺序为：先将服务部署到其他可用的机器，然后再将该服务从ec2实例移除

        ``skip_exist_service_for_start``为true，action=start时生效
        在找到满足条件的ec2实例中，如果服务已经存在，将不做任何事情
        """
        self.service_type = params['service_type']
        self.raw_service_type = params['raw_service_type']
        self.service_name = params['service_name']
        self.service = params['service']
        self.instance_type = params['instance_type']
        self.cpu = params['cpu']
        self.memory = params['memory']
        self.service_count = params['count']
        self.common_tags = params['tags']
        self.image_id = params['image_id']
        self.security_groups = params['security_groups']
        self.namespace = params['tags'].get('namespace', 'webservice')
        self.logfile = params['logfile']
        self.config_data = params['raw_config_data']
        self.aws_region = aws_region
        self.disable_update_code = disable_update_code
        self.action = action
        self.adjust = adjust
        self.skip_exist_service_for_start = skip_exist_service_for_start
        # 所有相关的ec2实例
        self.found_instances = []
        # 服务已经运行在ec2上的实例
        self.service_exist_instances = []
        # 满足条件可以部署服务的ec2实例
        self.satisfy_instances = []
        self.ec2 = Ec2(self.aws_region)
        self.s3 = boto3.client('s3')

        self.tags = []
        for k, v in self.common_tags.items():
            self.tags.append({'Key': k, 'Value': v})
        self.tags.append({'Key': 'serviceType', 'Value': self.service_type})
        self.tags.append({'Key': 'running_' + self.get_service_name(), 'Value': '%.2fCPU#%.2fG' % (self.cpu, self.memory)})

        _params = copy.deepcopy(params)
        del _params['raw_config_data']
        logger.debug('deploy service with params: %s', json.dumps(_params, indent=2))

    def deploy(self, byvpc=None, bysubnet=None, inner_ips=[]):
        self.aws_filters = []
        self.by_vpc = ''
        self.by_subnet = ''

        if not byvpc:
            byvpc = self.config_data.get('vpcId', None)
        if not bysubnet:
            bysubnet = self.config_data.get('subnetId', None)

        if byvpc:
            self.by_vpc = byvpc
            self.aws_filters.append(add_filters('vpc-id', self.by_vpc))
        if bysubnet:
            self.by_subnet = bysubnet
            self.aws_filters.append(add_filters('subnet-id', self.by_subnet))

        if inner_ips and len(inner_ips) > 0:
            self.aws_filters.append({'Name': 'private-ip-address', 'Values': inner_ips})

        self.find_ec2()
        logger.info('service=%s cpu=%.2f memory=%.2f instanceType=%s count=%d', self.service, self.cpu, self.memory, self.instance_type, self.service_count)

        if self.action in ['restart', 'stop'] and len(self.satisfy_instances) > 0:
            logger.info('%s %s...', self.action, self.service)
            ips = [i['privateIp'] for i in self.satisfy_instances]
            self.save_hosts_file(ips)
            return self.execute(ips)

        if self.action == 'start':
            return self.__start_service()
        return None

    def __start_service(self):
        ips = []
        adjust_instances = []
        need_correct_instances = []
        need_count = 0

        if len(self.satisfy_instances) + len(self.service_exist_instances) < self.service_count:
            need_count = self.service_count - len(self.satisfy_instances) - len(self.service_exist_instances)

        new_ec2_ips = []
        if need_count > 0:
            logger.warn('ec2 is not enough, launching %d ec2 instances' % need_count)
            new_ec2_ips = self.new_ec2(need_count)
            ips.extend(new_ec2_ips)

        # 选择需要部署服务的实例
        if self.service_count > len(self.service_exist_instances):
            ins = self.satisfy_instances[:self.service_count - len(self.service_exist_instances)]
            ips.extend([i['privateIp'] for i in ins])
            need_correct_instances.extend(ins)

        if not self.adjust:
            if not self.skip_exist_service_for_start:
                ips.extend([i['privateIp'] for i in self.service_exist_instances])
                need_correct_instances.extend(self.service_exist_instances)
        else:
            adjust_instances, transfer_instances, normal_instances = self.__filter_adjust_instances()
            if not self.skip_exist_service_for_start:
                ips.extend([i['privateIp'] for i in normal_instances])
                need_correct_instances.extend(normal_instances)

        if len(ips) > 0:
            logger.info('start %s', self.service)
            self.save_hosts_file(ips)
            self.execute(ips)
            self.correct_tags(need_correct_instances)
        else:
            logger.info('current %s service count is %s, desired count is %d, no need to start new ec2 and deploy', self.service, len(self.service_exist_instances), self.service_count)

        if len(self.service_exist_instances) > self.service_count:
            # cpu idle 又大到小排序
            self.service_exist_instances.sort(key=lambda i: i['idle']['cpu'])
            need_remove_service_instances = self.service_exist_instances[self.service_count:]
            ips = [i['privateIp'] for i in need_remove_service_instances]
            if len(need_remove_service_instances) > 0:
                questions = [inquirer.Confirm('continue', message="Start to remove %s from ec2 %s, Should I continue?" % (self.service, ', '.join(ips)), default=True)]
                answers = inquirer.prompt(questions)
                if answers and answers['continue']:
                    self.remove_service(need_remove_service_instances)
                    for i in copy.deepcopy(adjust_instances):
                        if i['privateIp'] in ips:
                            adjust_instances.remove(i)
                    # 修正ec2实例名称
                    self.correct_tags(need_remove_service_instances, True)
                else:
                    logger.info('Cancel remove service %s' % self.service)

        logger.info("\nadjust instances: %s" % ', '.join([i['privateIp'] for i in adjust_instances]))
        logger.info("transfer instances: %s\n" % ', '.join([i['privateIp'] for i in transfer_instances]))

        # 修正服务内存使用量
        # 如果需要调整的服务，有更适合的机器可以运行，那么将服务移动到转移列表
        if len(adjust_instances) > 0:
            questions = [inquirer.Confirm('continue', message="Start to adjust %s from ec2 %s, Should I continue?" %
                                          (self.service, ', '.join([i['privateIp'] for i in adjust_instances])), default=True)]
            answers = inquirer.prompt(questions)
            if answers and answers['continue']:
                self.__display_instances('starting adjust instances', copy.deepcopy(adjust_instances))

                if len(adjust_instances) > 0:
                    _ips = [i['privateIp'] for i in adjust_instances]
                    self.save_hosts_file(_ips)
                    self.execute(_ips, 'restart')

                    self.correct_tags(adjust_instances)
            else:
                logger.info('Cancel adjust service %s in %s', self.service, ', '.join([i['privateIp'] for i in adjust_instances]))

        # 将服务从一个ec2转移到另外一个ec2
        if len(transfer_instances) > 0:
            questions = [inquirer.Confirm('continue', message="Start to transfer %s from ec2 %s, Should I continue?" %
                                          (self.service, ', '.join([i['privateIp'] for i in transfer_instances])), default=True)]
            answers = inquirer.prompt(questions)
            if answers and answers['continue']:
                self.__display_instances('starting to transfer instances', copy.deepcopy(transfer_instances))

                # 重新扫描计算一次ec2实例
                self.find_ec2()

                will_start_service_instances = self.satisfy_instances[:len(transfer_instances)]
                ips = [i['privateIp'] for i in will_start_service_instances]

                need_count = 0
                if len(self.satisfy_instances) < len(transfer_instances):
                    need_count = len(transfer_instances) - len(self.satisfy_instances)

                if need_count > 0:
                    ips.extend(self.new_ec2(need_count))

                if len(ips) > 0:
                    self.save_hosts_file(ips)
                    self.execute(ips)
                    # wait
                    logger.warn('wait 120 seconds...')
                    time.sleep(120)
                    self.remove_service(transfer_instances)

                self.correct_tags(will_start_service_instances)
                self.correct_tags(transfer_instances, True)
            else:
                logger.info('Cancel transfer service %s in %s', self.service, ', '.join([i['privateIp'] for i in transfer_instances]))

        self.correct_target_group()
        self.check_terminable_instnaces()

        if len(new_ec2_ips) > 0:
            self.prometheus_action(new_ec2_ips)

    def correct_target_group(self):
        # if not self.config_data['targetGroupEnalbed']:
        #    return
        try:
            self.config_data['targetGroupEnalbed']
        except Exception:
            logger.error('no targetGroupEnalbed config file error', exc_info=True)
            return

        groups = self.config_data['targetGroups']
        group = None
        for g in groups:
            if g['service'] == self.service:
                group = g

        if group:
            ids = self.__get_target_group_instances(group['arn'])
            other_filters = []
            if self.by_vpc:
                other_filters = [{
                    'Name': 'vpc-id',
                    'Values': [self.by_vpc]
                }]
            result = self.ec2.get_instances_by_tag_key('running_%s' % self.service, other_filters)
            service_ids = self.__extract_instance_id(result)
            need_add_ids, need_remove_ids = self.__compare_service_ids(ids, service_ids)
            for i in need_add_ids:
                self.__add_instance_to_target_group(i, group['arn'])
            for i in need_remove_ids:
                self.__remove_instance_from_target_group(i, group['arn'])

    def __compare_service_ids(self, ids_in_group, ids_of_service):
        need_add_ids, need_remove_ids = [], []
        for i in ids_of_service:
            if i not in ids_in_group:
                need_add_ids.append(i)
        for i in ids_in_group:
            if i not in ids_of_service:
                need_remove_ids.append(i)
        return need_add_ids, need_remove_ids

    def __get_target_group_instances(self, target_group_arn):
        lb = LoadBlancing(self.aws_region)
        result = lb.describe_target_health(target_group_arn)
        ids = [r['Target']['Id'] for r in result['TargetHealthDescriptions']]
        return ids

    def __add_instance_to_target_group(self, id, target_group_arn):
        logger.info('adding %s to target group %s', id, target_group_arn)
        lb = LoadBlancing(self.aws_region)
        lb.register_target(target_group_arn, id)

        logger.info('waiting instance healthy...')
        timeout = time.time() + 60 * 5
        while True:
            result = lb.describe_target_health(target_group_arn, id)
            healthy_instances = [i for i in result['TargetHealthDescriptions'] if i['TargetHealth']['State'] == 'healthy']
            if len(healthy_instances) > 0:
                break

            if time.time() > timeout:
                logger.info('check target status timeout %s', result)
                break

            time.sleep(3)

    def __remove_instance_from_target_group(self, id, target_group_arn):
        logger.info('removing %s from target group %s', id, target_group_arn)
        lb = LoadBlancing(self.aws_region)
        lb.diregister_target(target_group_arn, id)

        # logger.info('waiting instance unused...')
        # timeout = time.time() + 60 * 5
        # while True:
        #     result = lb.describe_target_health(target_group_arn, id)
        #     unused_instances = [i for i in result['TargetHealthDescriptions'] if i['TargetHealth']['State'] == 'unused']
        #     if len(unused_instances) > 0:
        #         break

        #     if time.time() > timeout:
        #         logger.info('check target status timeout %s', result)
        #         break

        #     time.sleep(3)

    def check_terminable_instnaces(self):
        result = self.ec2.get_instances_by_name('bg.%s' % self.service_type)
        ids = self.__extract_instance_id(result)
        if len(ids) > 0:
            questions = [inquirer.Confirm('continue', message="Start to terminate empty ec2 instance: %s, Should I continue?" % ', '.join(ids), default=False)]
            answers = inquirer.prompt(questions)
            if answers and answers['continue']:
                result = self.ec2.terminate(ids)
                if result['ResponseMetadata']['HTTPStatusCode'] == 200:
                    logger.info('terminate %s success' % ', '.join(ids))
                else:
                    logger.error('since something going wrong, HttpStatusCode is %d' % result['ResponseMetadata']['HTTPStatusCode'] == 200)

    def __extract_instance_id(self, data):
        ids = []
        if data.has_key('Reservations') and len(data['Reservations']) > 0:
            for r in data['Reservations']:
                for i in r['Instances']:
                    if i['State']['Name'] == 'running':
                        ids.append(i['InstanceId'])
        return ids

    def __filter_adjust_instances(self):
        '''
        calculate and return adjust_instances, transfer_instances, normal_instances

        adjust_instances: 需要调整服务所需memory, cpu的实例
        transfer_instances: 需要将服务转移到其他ec2实例的实例
        normal_instances: 正常的实例
        '''
        adjust_instances = []
        transfer_instances = []
        normal_instances = []

        for i in self.service_exist_instances:
            need_more_memory = self.memory - i['memory']
            need_more_cpu = self.cpu - i['cpu']
            if need_more_memory != 0 or need_more_cpu != 0:
                logger.warn('%s memory %.2f to %.2f, cpu %.2f to %.2f', self.service, i['memory'], self.memory, i['cpu'], self.cpu)
                if (need_more_memory > 0 and i['idle']['memory'] < need_more_memory) or (need_more_cpu > 0 and i['idle']['cpu'] < need_more_cpu):
                    logger.warn("%s's memory idle is %.2f, %s need more memory %.2f", i['instanceId'], i['idle']['memory'], self.service, need_more_memory)
                    logger.warn("%s's cpu idle is %.2f, %s need more cpu %.2f", i['instanceId'], i['idle']['cpu'], self.service, need_more_cpu)
                    logger.warn('add %s inf instance %s to trasfer list', self.service, i['instanceId'])
                    transfer_instances.append(i)
                else:
                    logger.warn('add %s in instance %s to adjustment list', self.service, i['instanceId'])
                    adjust_instances.append(i)
                    for j in copy.deepcopy(self.satisfy_instances):
                        v_memory = j['idle']['memory'] - self.memory
                        v_cpu = j['idle']['cpu'] - self.cpu
                        if (v_memory > 0 and (i['idle']['memory'] - need_more_memory) > v_memory) and (v_cpu > 0 and (i['idle']['cpu'] - need_more_cpu) > v_cpu):
                            transfer_instances.append(i)
                            adjust_instances.remove(i)
                            self.satisfy_instances.remove(j)
                            break
            else:
                normal_instances.append(i)

        return adjust_instances, transfer_instances, normal_instances

    def remove_service(self, instances):
        '''
        remove service from instances
        '''
        self.save_hosts_file([i['privateIp'] for i in instances])
        self.run_command('%s/run.sh %s %s' % (CUR_DIR, self.service, 'remove'))
        self.ec2.delete_tags([i['instanceId'] for i in instances], [{'Key': 'running_%s' % self.service}])

    def correct_tags(self, instances, only_name=False):
        if instances and len(instances) > 0:
            ids = [i['instanceId'] for i in instances]
            result = self.ec2.describe_instances(instance_ids=ids)
            my_names = {}
            if result.has_key('Reservations') and len(result['Reservations']) > 0:
                for r in result['Reservations']:
                    for i in r['Instances']:
                        name = 'bg.%s' % self.service_type
                        for item in i['Tags']:
                            k = item['Key']
                            if k.startswith('running_'):
                                match_result = re.match(r'running_([a-z]+)-([a-z]+)', k)
                                if match_result:
                                    name += '.' + match_result.group(1)
                        my_names[i['InstanceId']] = name

            for id in ids:
                if my_names.has_key(id):
                    name = my_names[id]
                    tags = []
                    if not only_name:
                        if self.service_name not in name:
                            name += '.' + self.service_name
                        tags.extend(copy.deepcopy(self.tags))
                    tags.append({'Key': 'Name', 'Value': name})
                    self.ec2.create_tags([id], tags)

                    logger.info('correct ec2 tags for instance %s', id)
                    logger.info(fmt.format_as_table(tags, ['Key', 'Value']))

    def execute(self, ips, action=None):
        if not action:
            action = self.action

        profiles = self.config_data['profiles']
        profile_name = profiles.get(self.aws_region, None)
        if not profile_name:
            raise Exception('can not find profile name for aws region ' + self.aws_region)

        jvm_max_heap_memory = int(self.memory * 1024)
        jvm_min_heap_memory = int(self.memory * 1024)

        # self.run_command('%s/run.sh %s %s %s %s %s %s' % (CUR_DIR, self.get_service_name(), action, profile_name, jvm_max_heap_memory, jvm_min_heap_memory, self.get_register_center_config()))

        return self.__run(ips, 'service.yml', {
            'user_id': 'arthur wu',
            'repo_dir': self.config_data['repo_dir'],
            'build_dir': self.config_data['build_dir'],
            'service_type': self.config_data['raw_service_type'] in ['gateway', 'eureka'] and 'service' or self.config_data['raw_service_type'],
            'service': self.service,
            'service_action': action,
            'profile_name': profile_name,
            'jvm_max_heap_memory': jvm_max_heap_memory,
            'jvm_min_heap_memory': jvm_min_heap_memory,
            'eureka_client_serviceUrl_defaultZone': self.get_register_center_config(),
            'template_dir': os.path.join(CUR_DIR, 'templates'),
            'disable_update_code': self.disable_update_code,
            'logfile': self.logfile
        })

    def prometheus_action(self, ips):
        self.deploy_prometheus_node_exporter()

        result = self.ec2.get_instances_by_private_ips(ips)
        if len(result['Reservations']) > 0 and len(result['Reservations'][0]['Instances']) > 0:
            public_ips = [i['PublicIpAddress'] for i in result['Reservations'][0]['Instances']]
            self.add_target_to_prometheus_config(public_ips)
            self.add_nodes_to_prometheus_config(public_ips)

    def deploy_prometheus_node_exporter(self):
        cmd = 'ansible-playbook -i ./hosts-webservice yml/node_exporter.yml --extra-vars="service=%s"' % self.service
        self.run_command(cmd)

    def add_target_to_prometheus_config(self, public_ips):
        bucket = "blockmango-res"
        key = "monitoring/config/webservice-groups.json"
        try:
            jobs = []
            try:
                res = self.s3.get_object(Bucket=bucket, Key=key, ResponseContentType="application/json")
                logger.info(res)
                jobs = json.loads(res['Body'].read())
            except:
                logger.error('get tgroups.json error:', exc_info=True)

            _, service_metrics_port = get_service_ports(self.service, self.service_type, self.aws_region, self.config_data)

            found = False
            for job in jobs:
                if job['labels'].get('job', '') == self.service:
                    for ip in public_ips:
                        host = '%s:%d' % (ip, service_metrics_port)
                        if host not in job['targets']:
                            job['targets'].append(host)
                    found = True

            if not found:
                j = {'labels': {'job': self.service}, 'targets': []}
                for ip in public_ips:
                    host = '%s:%d' % (ip, service_metrics_port)
                    j['targets'].append(host)
                jobs.append(j)

            ret = self.s3.put_object(Bucket=bucket, Key=key, Body=json.dumps(jobs, indent=2), ContentType='application/json')
            if ret and ret['ResponseMetadata']['HTTPStatusCode'] == 200:
                logger.debug('add public ips success %s' % public_ips)
                logger.info("update prometheus config success, key=%s %s" % (key, jobs))
        except Exception as e:
            logger.error('update prometheus config file error', exc_info=True)

    def add_nodes_to_prometheus_config(self, public_ips):
        bucket = "blockmango-res"
        key = "monitoring/config/webservice-nodes-groups.json"
        try:
            jobs = []
            try:
                res = self.s3.get_object(Bucket=bucket, Key=key, ResponseContentType="application/json")
                logger.info(res)
                jobs = json.loads(res['Body'].read())
            except:
                logger.error('get tgroups.json error:', exc_info=True)

            found_nodes = False
            for job in jobs:
                if job['labels'].get('job', '') == 'nodes' and job['labels'].get('region', '') == self.aws_region:
                    for ip in public_ips:
                        job['targets'].append('%s:9100' % ip)

            if not found_nodes:
                j = {'labels': {'job': 'nodes', 'region': self.aws_region}, 'targets': []}
                for ip in public_ips:
                    j['targets'].append('%s:9100' % ip)
                jobs.append(j)

            ret = self.s3.put_object(Bucket=bucket, Key=key, Body=json.dumps(jobs, indent=2), ContentType='application/json')
            if ret and ret['ResponseMetadata']['HTTPStatusCode'] == 200:
                logger.info("update prometheus config success, key=%s %s" % (key, jobs))
        except Exception as e:
            logger.error('update prometheus config file error', exc_info=True)

    def run_command(self, cmd):
        logger.warn('run command: %s work_dir=%s ', cmd, CUR_DIR)
        # p = subprocess.Popen(cmd,
        #                      cwd=CUR_DIR,
        #                      shell=True,
        #                      stdout=subprocess.PIPE,
        #                      stderr=subprocess.STDOUT
        #                      )

        # returncode = p.poll()
        # while returncode is None:
        #     line = p.stdout.readline()
        #     returncode = p.poll()
        #     line = line.strip()
        #     if 'BUILD FAILED' in line:
        #         logger.critical(line)
        #     elif 'BUILD SUCCESSFUL' in line:
        #         logger.warn(line)
        #     else:
        #         logger.info(line)

        # logger.info('command execute return code: %s', returncode)

    def __run(self, hostnames, playbook, run_data, remote_user='deploy'):
        print '__run', hostnames, playbook, run_data
        runner = Runner(hostnames, playbook, run_data, remote_user, playbook_dir=os.path.join(CUR_DIR, 'yml'))
        stats = runner.run()
        return stats

    def find_ec2(self):
        only_service = None

        if self.action in ['restart', 'reload', 'stop']:
            only_service = self.service
        instances = self.__get_ec2_instances(only_service)

        self.found_instances = copy.deepcopy(instances)

        if self.action == 'start':
            service_exist_instances = [i for i in instances if self.service in i['serviceName']]
            self.service_exist_instances = copy.deepcopy(service_exist_instances)
            satisfy_instances = []
            for i in instances:
                if self.service not in i['serviceName'] and i['idle']['cpu'] >= self.cpu and i['idle']['memory'] >= self.memory:
                    satisfy_instances.append(i)
            need_count = self.service_count - len(service_exist_instances)
            # 排序，优先选取内存空闲多的机器
            satisfy_instances.sort(key=lambda i: i['idle']['memory'])
            # satisfy_instances = satisfy_instances[:need_count]
            self.satisfy_instances = satisfy_instances
        else:
            self.satisfy_instances = instances

        self.__display_instances('found instnaces', copy.deepcopy(self.found_instances))
        self.__display_instances('service exist instances', copy.deepcopy(self.service_exist_instances))
        self.__display_instances('satisfy instances to start new service', copy.deepcopy(self.satisfy_instances))

    def __display_instances(self, title, instances):
        data = copy.deepcopy(instances)
        for i in data:
            i['serviceName'] = [s.replace('-' + self.service_type, '') for s in i['serviceName']]
        logger.warn(title)
        logger.info(fmt.format_as_table(data, ['privateIp', 'serviceType', 'serviceName', 'idle', 'instanceId']))

    def __has_reserved_instance(self):
        if self.config_data.has_key('reservedInstance'):
            return True
        return False

    def __get_reserved_instance_info(self):
        items = self.config_data['reservedInstance']
        for i in items:
            if i['serviceType'] == self.service_type:
                return i['instanceType'], i['count']
        return '', 0

    def __add_reserved_instance_type(self, filters):
        it, _ = self.__get_reserved_instance_info()

        for f in filters:
            if f['Name'] == 'instance-type':
                f['Values'].append(it)

    def __get_inused_reserved_instance_count(self, instance_type):
        result = self.ec2.get_instances_by_tags({}, [{'Name': 'instance-type', 'Values': [instance_type]}])

        if result.has_key('Reservations') and len(result['Reservations']) > 0:
            return len(result['Reservations'][0]['Instances'])
        return 0

    def __get_ec2_instances(self, service=None):
        other_filters = [{
            'Name': 'instance-type',
            'Values': [self.instance_type]
        }]
        other_filters.extend(self.aws_filters)

        if self.__has_reserved_instance():
            self.__add_reserved_instance_type(other_filters)

        if service:
            other_filters.append({
                'Name': 'tag-key',
                'Values': ['running_%s' % service]
            })
        if self.service_type == "remixinstall":
            result = self.ec2.get_instances_by_tags({
                'namespace': self.namespace,
            }, other_filters)
        else:
            result = self.ec2.get_instances_by_tags({
                'namespace': self.namespace,
                'serviceType': self.service_type
            }, other_filters)

        instances = []
        if result.has_key('Reservations') and len(result['Reservations']) > 0:
            for r in result['Reservations']:
                for i in r['Instances']:
                    if i['State']['Name'] == 'running':
                        ins = {
                            'instanceId': i['InstanceId'],
                            'privateIp': i['PrivateIpAddress'],
                            'idle': self.__calculate_idle(i['Tags'], i['InstanceType']),
                            'serviceType': self.service_type,
                            'serviceName': []
                        }
                        for t in i['Tags']:
                            k = t['Key']
                            match_result = re.match(r'running_(\S+)', k)
                            if match_result:
                                service_name = match_result.group(1)
                                ins['serviceName'].append(service_name)
                            if k == 'running_%s' % self.service:
                                result = re.match(r'(\S+)CPU#(\S+)G', t['Value'])
                                if result:
                                    cpu = float(result.group(1))
                                    memory = float(result.group(2))
                                    ins['cpu'] = round(cpu, 2)
                                    ins['memory'] = round(memory, 2)
                        instances.append(ins)
        return instances

    def __calculate_idle(self, tags, instance_type):
        cpu = 0.0
        memory = 0.0
        for t in tags:
            if t['Key'].startswith('running_'):
                result = re.match(r'(\S+)CPU#(\S+)G', t['Value'])
                if result:
                    cpu += float(result.group(1))
                    memory += float(result.group(2))

        total_cpu, total_memory = self.get_instance_details(instance_type)
        return {'cpu': round(total_cpu - cpu, 2), 'memory': round(total_memory - memory, 2)}

    def get_instance_details(self, instance_type):
        reserved_cpu = float(self.config_data['reservedCpu'])
        reserved_memory = float(self.config_data['reservedMemory'])

        for i in self.config_data['instanceTypeDetails']:
            if i['name'] == instance_type:
                return round(max(float(i['cpu']) - reserved_cpu, 0.0), 2), round(max(float(i['memory']) - reserved_memory, 0.0), 2)

        raise Exception('can not find instance info for %s' % instance_type)

    def new_ec2(self, count):
        ips = []

        instance_tags = {}
        for t in self.tags:
            instance_tags[t['Key']] = t['Value']
        instance_tags['running_' + self.service] = '%.2fCPU#%.2fG' % (self.cpu, self.memory)
        instance_tags['Name'] = 'bg.%s.%s' % (self.service_type, self.service_name)

        user_data = '''#!/bin/bash
        echo '%s' >> /home/ubuntu/.ssh/authorized_keys
        ''' % self.__read_id_rsa_pub()

        if self.__has_reserved_instance():
            it, total_count = self.__get_reserved_instance_info()
            used_count = self.__get_inused_reserved_instance_count(it)
            remaind_count = total_count - used_count
            if remaind_count > 0:
                start_count = min(remaind_count, count)
                count = count - start_count

                logger.info('total remaind reserved isntances count is %d', remaind_count)
                logger.info('launching reserved instgance for service, instanceType=%s count=%d', it, start_count)
                result = self.ec2.launch(start_count, ima_id=self.image_id, instance_type=it, sgs=self.security_groups, subnet=self.by_subnet,
                                         vpc=self.by_vpc, tags=instance_tags, user_data=user_data, instance_profile={'Name': 's3-reader-writer'})
                instances = result['Instances']
                for ins in instances:
                    ips.append(ins['PrivateIpAddress'])

        if count > 0:
            # 没有指定subnet，默认从default vpc选择一个default subnet
            result = self.ec2.launch(count, ima_id=self.image_id, instance_type=self.instance_type, sgs=self.security_groups, subnet=self.by_subnet,
                                     vpc=self.by_vpc, tags=instance_tags, user_data=user_data, instance_profile={'Name': 's3-reader-writer'})
            instances = result['Instances']
            for ins in instances:
                ips.append(ins['PrivateIpAddress'])

        logger.info('new ec2 result: %s', ','.join(ips))
        logger.info('wait instance ssh connetivity...')
        # 等待room服务器的ssh服务可用
        # if not self.wait_ssh_connectivity(ips[0]):
        #    time.sleep(60)

        return ips

    def __read_id_rsa_pub(self):
        file_path = os.path.expanduser('~/.ssh/id_rsa.pub')
        if not os.path.exists(file_path):
            return ''
        f = open(file_path, 'r')
        content = f.read()
        f.close()
        return content

    def get_register_center_config(self):
        myFilters = [{'Name': 'tag-key', 'Values': ['running_eureka-service']}]
        result = self.ec2.get_instances_by_tags(tags={'namespace': self.namespace}, other_filters=myFilters)
        ips = []
        if result.has_key('Reservations') and len(result['Reservations']) > 0:
            for r in result['Reservations']:
                for i in r['Instances']:
                    if i['State']['Name'] == 'running':
                        ips.append(i['PrivateIpAddress'])
        return '\\\\,'.join(['http://%s:8761/eureka/' % ip for ip in ips])

    def wait_ssh_connectivity(self, ip):
        hostname = 'ip-%s' % ip.replace('.', '-')
        cmd = 'ssh deploy@%s hostname' % ip

        ok = False
        times = 2
        while not ok and times > 0:
            p = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
            returncode = p.poll()
            while returncode is None:
                line = p.stdout.readline()
                returncode = p.poll()
                if hostname in line:
                    ok = True
            times -= 1
        return ok

    def save_hosts_file(self, ips):
        tmpips = copy.deepcopy(ips)
        if self.service == 'eureka-service':  # and len(ips) == 2:
            profiles = self.config_data['profiles']
            profile_name = profiles.get(self.aws_region, None)
            if not profile_name:
                raise Exception('can not find profile name for aws region ' + self.aws_region)
            ips[0] = '%s profile_name=%s ' % (ips[0], profile_name)
            if len(ips) == 2:
                ips[0] = '%s profile_name=peers2 peersip=%s name=peers1' % (ips[0], tmpips[1])
                ips[1] = '%s profile_name=%s peersip=%s name=peers2' % (ips[1], profile_name, tmpips[0])
        cfgParser = ConfigParser.ConfigParser(allow_no_value=True)
        name = self.get_service_name()
        cfgParser.add_section(name)
        for ip in ips:
            cfgParser.set(name, ip)
        cfgParser.write(
            open('hosts-webservice', 'w+'))

        logger.info('save to hosts file: name=%s ips=%s', name, ips)

    def get_service_name(self):
        return self.service

    def set_logger_file(self, filepath, level='INFO'):
        logger_config.config_logging(filepath, level)


class ServiceList:
    by_instances = False

    def __init__(self, aws_region, config_data=None):
        self.config_data = config_data
        self.namespace = config_data['tags'].get('namespace', 'webservice')
        self.aws_region = aws_region
        self.ec2 = Ec2(aws_region)
        self.s3 = boto3.client('s3')

    def list(self, service, by_instances=False, byvpc=None, bysubnet=None):
        self.by_instances = by_instances
        self.aws_filters = []
        if byvpc:
            self.by_vpc = byvpc
            self.aws_filters.append(add_filters('vpc-id', self.by_vpc))

        if bysubnet:
            self.by_subnet = bysubnet
            self.aws_filters.append(add_filters('subnet-id', self.by_subnet))

        if not service or service == '':
            self.display_all()
        else:
            self.display_service(service)

    def get_service_list(self):
        tags = [
            {
                'Name': 'tag:namespace',
                'Values': [self.namespace]
            }
        ]
        services, instances = self.__get_service(tags)
        services = self.__add_service_ports(services)
        return services, instances

    def correct_prometheus_webservice_static_config_file(self):
        tags = [
            {
                'Name': 'tag:namespace',
                'Values': [self.namespace]
            }
        ]
        services, _ = self.__get_service(tags)
        services = self.__add_service_ports(services)
        self.__update_jobs(services)
        logger.info(fmt.format_as_table(copy.deepcopy(services), ['serviceName', 'privateIp', 'publicIp', 'instanceId',
                                                                  'serviceType', 'cpuUsage', 'memoryUsage', 'ec2Status', 'port', 'metricsPort'], sort_by_key='serviceName'))

    def __add_service_ports(self, services):
        ports = {}

        for s in services:
            if ports.has_key(s['serviceName']):
                s['port'] = ports[s['serviceName']]['port']
                s['metricsPort'] = ports[s['serviceName']]['metricsPort']
            else:
                sinfo = extract_service_info(self.config_data, s['serviceName'])
                port, metrics_port = get_service_ports(s['serviceName'], sinfo['raw_service_type'], self.aws_region, self.config_data)
                s['port'] = port
                s['metricsPort'] = metrics_port
                ports[s['serviceName']] = {'port': port, 'metricsPort': metrics_port}

        return services

    def __update_jobs(self, services):
        bucket = "blockmango-res"
        key = "monitoring/config/webservice-groups.json"
        try:
            jobs = []
            # try:
            #     res = self.s3.get_object(Bucket=bucket, Key=key, ResponseContentType="application/json")
            #     logger.info(res)
            #     jobs = json.loads(res['Body'].read())
            # except:
            #     logger.error('get tgroups.json error:', exc_info=True)

            for s in services:
                service = s['serviceName']
                ip = s['publicIp']
                service_metrics_port = s['metricsPort']

                if service == 'eureka-service':
                    continue

                found = False
                for job in jobs:
                    if job['labels'].get('job', '') == service:
                        host = '%s:%d' % (ip, service_metrics_port)
                        if host not in job['targets']:
                            job['targets'].append(host)
                        found = True

                if not found:
                    j = {'labels': {'job': service}, 'targets': []}
                    host = '%s:%d' % (ip, service_metrics_port)
                    j['targets'].append(host)
                    jobs.append(j)

            ret = self.s3.put_object(Bucket=bucket, Key=key, Body=json.dumps(jobs, indent=2), ContentType='application/json')
            if ret and ret['ResponseMetadata']['HTTPStatusCode'] == 200:
                logger.info("update prometheus config success, key=%s %s" % (key, jobs))
        except Exception as e:
            logger.error('update prometheus config file error', exc_info=True)

    def connect(self, service):
        tags = [
            {
                'Name': 'tag:namespace',
                'Values': [self.namespace]
            },
            {
                'Name': 'tag-key',
                'Values': ['running_%s' % service]
            }
        ]
        services, _ = self.__get_service(tags, service)
        ips = [s['privateIp'] for s in services]
        if not ips or len(ips) == 0:
            logger.warn('there is no instances for "%s", please input a valid service name' % service)
            exit(1)

        questions = [
            inquirer.List('ip',
                          message="Which instance do you want to connect?",
                          choices=ips,
                          carousel=True
                          ),
        ]
        answers = inquirer.prompt(questions)
        if answers:
            with open('.selected_host', 'w+') as f:
                f.write(answers['ip'])
            exit(0)
        else:
            exit(1)

    def display_all(self):
        tags = [
            {
                'Name': 'tag:namespace',
                'Values': [self.namespace]
            }
        ]

        tags.extend(self.aws_filters)
        self.__display(tags)

    def display_service(self, service):
        tags = [
            {
                'Name': 'tag:namespace',
                'Values': [self.namespace]
            },
            {
                'Name': 'tag-key',
                'Values': ['running_%s' % service]
            }
        ]
        tags.extend(self.aws_filters)
        self.__display(tags, service)

    def __display(self, tags, service=None):
        services, instances = self.__get_service(tags, service)
        if not self.by_instances:
            self.__list_service_details(services)
        else:
            self.__list_service_details_by_instances(instances)

    def __list_service_details_by_instances(self, instances):
        total_cpu_usage = 0.0
        total_memory_usage = 0.0
        total_cpu_idle = 0.0
        total_memory_idle = 0.0
        for ins in instances:
            #            serviceType = ins['serviceType']
            serviceType = ins.get('serviceType', None)
            service_type_info = None
            for t in self.config_data['serviceTypes']:
                if t['type'] == serviceType:
                    service_type_info = t

            if not service_type_info:
                logger.info('can not find service type info for ')
#                raise Exception('can not find service type info for ' + serviceType)

            ins_info = None
            for i in self.config_data['instanceTypeDetails']:
                if i['name'] == ins['instanceType']:
                    ins_info = i

            if not ins_info:
                raise Exception('can not find instance details for ' + service_type_info['type'])

            total_cpu = ins_info['cpu']
            total_memory = ins_info['memory']
            ins['cpuIdle'] = round(float(total_cpu) - float(ins['cpuUsage']) - float(self.config_data['reservedCpu']), 2)
            ins['memoryIdle'] = round(float(total_memory) - float(ins['memoryUsage']) - float(self.config_data['reservedMemory']), 2)
            ins['cpuReserved'] = self.config_data['reservedCpu']
            ins['memoryReserved'] = self.config_data['reservedMemory']

            total_cpu_idle += ins['cpuIdle']
            total_memory_idle += ins['memoryIdle']
            total_cpu_usage += float(ins['cpuUsage'])
            total_memory_usage += float(ins['memoryUsage'])

        logger.info(fmt.format_as_table(instances, ['name', 'cpuUsage', 'memoryUsage', 'cpuIdle', 'memoryIdle', 'instanceId',
                                                    'instanceType', 'privateIp', 'publicIp', 'ec2Status', 'cpuReserved', 'memoryReserved'], sort_by_key='memoryIdle'))
        logger.warn("Total EC2 Instances: %d" % len(instances))
        logger.warn("Total Cpu Usage: %.2f" % total_cpu_usage)
        logger.warn("Total Memory Usage: %.2f" % total_memory_usage)
        logger.warn("")
        logger.warn("Total Cpu Idle: %.2f" % total_cpu_idle)
        logger.warn("Total Memory Idle: %.2f" % total_memory_idle)
        logger.warn("")

    def __sum_cup_memory(self, items, serviceType):
        cpu = 0.0
        memory = 0.0
        for i in items:
            for k in i.keys():
                if k.startswith('running_'):
                    result = re.match(r'(\S+)CPU#(\S+)G', i[k])
                    if result:
                        cpu += float(result.group(1))
                        memory += float(result.group(2))
        service_type_info = None
        for t in self.config_data['serviceTypes']:
            if t['type'] == serviceType:
                service_type_info = t

        if not service_type_info:
            logger.critical('can not find service type info for ' + serviceType)
            exit(1)

        ins_info = None
        for i in self.config_data['instanceTypeDetails']:
            if i['name'] == service_type_info['instanceType']:
                ins_info = i

        if not ins_info:
            logger.critical('can not find instance details for ' + service_type_info['type'])
            exit(1)

        total_cpu = ins_info['cpu']
        total_memory = ins_info['memory']
        return cpu, memory, total_cpu, total_memory

    def __list_service_details(self, services):
        logger.info(fmt.format_as_table(copy.deepcopy(services), ['serviceName', 'privateIp', 'publicIp',
                                                                  'instanceId',  'serviceType', 'cpuUsage', 'memoryUsage', 'ec2Status'], sort_by_key='serviceName'))
        groups = itertools.groupby(services, lambda s: s.get('instanceId'))
        ids = [i for i, _ in groups]
        logger.warn("Total EC2 Instances: %d  in %s vpc of %s region" % (len(ids), self.by_vpc, self.aws_region))
        logger.warn('Total Running Service Instances: %d' % len(services))
        groups = itertools.groupby(services, lambda s: s.get('serviceName'))
        names = [k for k, _ in groups]
        logger.warn('Total Services: %d' % len(set(names)))

    def __get_service(self, tags, service=None):
        result = self.ec2.describe_instances(filters=tags)
        services = []
        instances = []
        if result.has_key('Reservations') and len(result['Reservations']) > 0:
            for r in result['Reservations']:
                for i in [j for j in r['Instances'] if j['State']['Name'] == 'running']:
                    ins = {
                        'instanceId': i['InstanceId'],
                        'privateIp': i['PrivateIpAddress'],
                        'publicIp': i['PublicIpAddress'],
                        'ec2Status': i['State']['Name'],
                        'instanceType': i['InstanceType']
                    }
                    cpu_usage, memory_usage = .0, .0
                    svc = {}

                    for item in i['Tags']:
                        if item['Key'] == 'serviceType':
                            ins['serviceType'] = item['Value']
                        if item['Key'] == 'Name':
                            ins['name'] = item['Value']

                    for item in i['Tags']:
                        k = item['Key']
                        v = item['Value']
                        if k.startswith('running_'):
                            svc[k] = v
                            match_result = re.match(r'running_(\S+)', k)
                            service_name = service
                            if match_result:
                                service_name = match_result.group(1)

                            # 只计算指定service的cpu和memory使用量，非指定service跳过
                            if not self.by_instances and service and service_name != service:
                                continue
                            match_result = re.match(r'(\S+)CPU#(\S+)G', v)
                            if match_result:
                                cpu = match_result.group(1)
                                memory = match_result.group(2)
                                svc['cpuUsage'] = cpu
                                svc['memoryUsage'] = memory + 'G'
                                cpu_usage += float(cpu)
                                memory_usage += float(memory)
                            svc['serviceName'] = service_name
                            svc['id'] = '%s:%s' % (ins['instanceId'], service_name)

                            services.append(dict(ins.items() + svc.items()))
                    ins['cpuUsage'] = '%.2f' % cpu_usage
                    ins['memoryUsage'] = '%.2f' % memory_usage
                    instances.append(ins)
        return services, instances


class ServiceStateDisiredCheck:
    def __init__(self, aws_region, service_config, adjust=False, skip_exist_service_for_start=False, action='start', vpc=None, subnet=None):
        self.aws_region = aws_region
        self.service_config = service_config
        self.adjust = adjust
        self.skip_exist_service_for_start = skip_exist_service_for_start
        self.action = action
        self.ec2 = Ec2(aws_region)
        if vpc:
            self.vpc = vpc
        if subnet:
            self.subnet = subnet

    def execute(self):
        groupsDict = {}
        for c in self.service_config:
            if not groupsDict.has_key(c['service_type']):
                groupsDict[c['service_type']] = [c]
            else:
                groupsDict[c['service_type']].append(c)

        groups = []
        groups.append(groupsDict.get('eureka', []))
        groups.append(groupsDict.get('gateway', []))
        groups.append(groupsDict.get('center', []))
        groups.append(groupsDict.get('service', []))
        groups.append(groupsDict.get('remixinstall', []))

        for services in groups:
            for svc in services:
                task = Deployer(self.aws_region, self.action, svc, adjust=self.adjust, skip_exist_service_for_start=self.skip_exist_service_for_start)
                task.deploy(self.vpc, self.subnet)


class PrometheusNodeExporter:
    def __init__(self, aws_region):
        self.aws_region = aws_region
        self.ec2 = Ec2(aws_region)
        self.s3 = boto3.client('s3')

    def execute(self):
        ips, public_ips = self.__get_ips()
        self.__save_all_ips(ips)
        self.__deploy_prometheus_node_exporter()
        self.__update_jobs(public_ips)

    def __save_all_ips(self, ips):
        cfgParser = ConfigParser.ConfigParser(allow_no_value=True)
        cfgParser.add_section("nodes")
        for ip in ips:
            cfgParser.set("nodes", ip)
        cfgParser.write(
            open('hosts-webservice', 'w+'))

        logger.info('save to hosts file: name=%s ips=%s', "nodes", ips)

    def __get_ips(self):
        results = self.ec2.get_instances_by_tags({"namespace": "webservice"})
        ips, pips = self.__extract_instance_ip(results)
        return ips, pips

    def __extract_instance_ip(self, data):
        ips = []
        public_ips = []
        if data.has_key('Reservations') and len(data['Reservations']) > 0:
            for r in data['Reservations']:
                for i in r['Instances']:
                    if i['State']['Name'] == 'running':
                        ips.append(i['PrivateIpAddress'])
                        public_ips.append(i['PublicIpAddress'])
        return ips, public_ips

    def __deploy_prometheus_node_exporter(self):
        cmd = 'ansible-playbook -i ./hosts-webservice -u ubuntu yml/node_exporter.yml --extra-vars="service=nodes"'
        self.__run_command(cmd)

    def __run_command(self, cmd):
        logger.warn('run command: %s work_dir=%s ', cmd, CUR_DIR)
        p = subprocess.Popen(cmd,
                             cwd=CUR_DIR,
                             shell=True,
                             stdout=subprocess.PIPE,
                             stderr=subprocess.STDOUT
                             )

        returncode = p.poll()
        while returncode is None:
            line = p.stdout.readline()
            returncode = p.poll()
            line = line.strip()
            if 'BUILD FAILED' in line:
                logger.critical(line)
            elif 'BUILD SUCCESSFUL' in line:
                logger.warn(line)
            else:
                logger.info(line)

        logger.info('command execute return code: %s', returncode)

    def __update_jobs(self, public_ips):
        bucket = "blockmango-res"
        key = "monitoring/config/webservice-nodes-groups.json"
        try:
            jobs = []
            # try:
            #     res = self.s3.get_object(Bucket=bucket, Key=key, ResponseContentType="application/json")
            #     logger.info(res)
            #     jobs = json.loads(res['Body'].read())
            # except:
            #     logger.error('get tgroups.json error:', exc_info=True)

            # found_nodes = False
            # for job in jobs:
            #     if job['labels'].get('job', '') == 'nodes' and job['labels'].get('region', '') == self.aws_region:
            #         job['targets'] = []
            #         for ip in public_ips:
            #             job['targets'].append('%s:9100' % ip)
            #         found_nodes = True

            # if not found_nodes:
            j = {'labels': {'job': 'nodes', 'region': self.aws_region, 'service': 'webapi'}, 'targets': []}
            for ip in public_ips:
                j['targets'].append('%s:9100' % ip)
            jobs.append(j)

            ret = self.s3.put_object(Bucket=bucket, Key=key, Body=json.dumps(jobs, indent=2), ContentType='application/json')
            if ret and ret['ResponseMetadata']['HTTPStatusCode'] == 200:
                logger.info("update prometheus config success, key=%s %s" % (key, jobs))
        except Exception as e:
            logger.error('update prometheus config file error', exc_info=True)


def inner_ip_address():
    response = urllib2.urlopen('http://169.254.169.254/latest/meta-data/local-ipv4')
    return response.read()


def public_ip_address():
    response = urllib2.urlopen('http://169.254.169.254/latest/meta-data/public-ipv4')
    return response.read()


def current_aws_region():
    if AWS_REGION:
        return AWS_REGION

    response = urllib2.urlopen('http://169.254.169.254/latest/meta-data/placement/availability-zone')
    az = response.read()
    return az[:-1]


def parse_config_file(configfile):
    f = open(configfile, 'r')
    config_data = yaml.load(f.read())
    f.close()
    logger.debug('parse config file result: \n%s', json.dumps(config_data, indent=2))
    return config_data


def extract_service_info(data, service, **kwargs):
    if service not in data['serviceNames']:
        logger.error('service name "%s" is invalid, please input one of:' % service)
        for s in data['serviceNames']:
            logger.info('\t%s' % s)
        return None

    result = re.match(r'([a-z]+)-([a-z]+)', service)
    if not result:
        logger.error('service invalid: %s', service)
        return None
    service_name = result.group(1)
    service_type = result.group(2)

    if service == 'message-process':
        service_name = service
        service_type = 'service'
    if service == 'gateway-service':
        service_type = 'gateway'
    if service == 'eureka-service':
        service_type = 'eureka'

    count = int(data.get('defaultServiceCount', 0))
    instance_type = data.get('defaultInstanceType', 'c4.large')
    cpu = float(data.get('defaultServiceCpu', 0.1))
    memory = float(data.get('defaultServiceMemory', 0.2))
    data['raw_service_type'] = service_type

    for t in data.get('serviceTypes', []):
        if t['type'] == service_type:
            remix_tag = t.get('remix', False)
            instance_type = t.get('instanceType', instance_type)
            cpu = float(t.get('cpu', cpu))
            memory = float(t.get('memory', memory))
            count = int(t.get('count', count))

            if remix_tag:
                service_type = 'remixinstall'

    for s in data.get('services', []):
        if s['name'] == service:
            remix_tag = s.get('remix', False)
            cpu = float(s.get('cpu', cpu))
            memory = float(s.get('memory', memory))
            count = int(s.get('count', count))

            if remix_tag:
                service_type = 'remixinstall'

    if kwargs.has_key('count') and kwargs.get('count'):
        count = int(kwargs.get('count', count))
    if kwargs.has_key('cpu') and kwargs.get('cpu'):
        cpu = float(kwargs.get('cpu', cpu))
    if kwargs.has_key('memory') and kwargs.get('memory'):
        memory = float(kwargs.get('memory', memory))
    if kwargs.has_key('instance_type') and kwargs.get('instance_type'):
        instance_type = kwargs.get('instance_type', instance_type)

    return {
        'instance_type': instance_type,
        'service_type': service_type,
        'raw_service_type': data['raw_service_type'],
        'service_name': service_name,
        'service': service,
        'count': count,
        'cpu': cpu,
        'memory': memory,
        'image_id': data['imageId'],
        'security_groups': data['securityGroups'],
        'tags': data['tags'],
        'raw_config_data': data
    }


def parse_all_service_config(configfile):
    data = parse_config_file(configfile)
    items = []
    for name in data['serviceNames']:
        p = extract_service_info(data, name)
        if p:
            items.append(p)
    return items


def get_service_ports(service, service_type, aws_region, config_data):
    service_port = 0
    service_metrics_port = 0

    if service == 'message-process':
        service_type = 'process'
    if service in ['gateway-service', 'eureka-service']:
        service_type = 'service'
    fp = os.path.join(config_data['repo_dir'], 'server', 'com', 'sandbox', service_type, service, 'src/main/resources/application.yml')
    if not os.path.exists(fp):
        print fp, 'not exists'
        return service_port, service_metrics_port

    f = open(fp, 'r')
    text = f.read()
    text = text.replace('{{', '', 10).replace('}}', '', 10)
    apps_config = list(yaml.load_all(text))
    f.close()

    profiles = config_data['profiles']
    profile_name = profiles.get(aws_region, None)
    if not profile_name:
        raise Exception('can not find profile name for aws region ' + aws_region)

    for a in apps_config:
        spring = a.get('spring', None)
        if spring and spring.get('profiles', None) == profile_name:
            pass

        server = a.get('server', None)
        if server and server.get('port', None):
            service_port = int(server['port'])
        management = a.get('management', None)
        if management and management['server']['port']:
            service_metrics_port = int(management['server']['port'])

    return service_port, service_metrics_port


def parse_args():
    description = u'''
    Java Web服务部署脚本
    '''

    parser = argparse.ArgumentParser(description=description, formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    parser.add_argument('-c', '--config-file', default='./config.yaml', help=u'config file path')

    subparsers = parser.add_subparsers(dest='command', title='optional commands', description=u'command to execute, please use deployer.py [command] -h to check the help infomation')

    # deploy
    parser_deploy = subparsers.add_parser('deploy', help=u'deploy services', formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    parser_deploy.add_argument('-a', '--action', required=True, choices=['start', 'stop', 'restart'], help=u'action to oprate the service')
    parser_deploy.add_argument('-s', '--service', required=True, help=u'service name, eg: game-service')
    parser_deploy.add_argument('--count', help=u'service instances count')
    parser_deploy.add_argument('--instance-type', help=u'ec2 instance type')
    parser_deploy.add_argument('--cpu', help=u'cpu usage needed for service. eg: 1.4')
    parser_deploy.add_argument('--memory', help=u'memory usage needed for service, unit is GigaByte. eg: 1.8 is 1.8G')
    parser_deploy.add_argument('--disable-skip', action='store_true', help=u'disable skiping service exist ec2 instance when action is start')
    parser_deploy.add_argument('--disable-adjust', action='store_true',
                               help=u"disable adjust running service on ec2 instance when action is start, 'adjust' make sure ec2 instance's cpu and memory usage less than the limit")
    parser_deploy.add_argument('--debug', action='store_true', help=u'set logger level debug, default level is info')

    # list
    parser_list = subparsers.add_parser('list', help=u'list current deployed service', formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    parser_list.add_argument('-s', '--service', help=u'service name, if you not specific any service will display all')
    parser_list.add_argument('-i', '--by-instances', action='store_true', help=u'list service by instance, include cpu, memory usage and capacity')
    parser_list.add_argument('--correct-prometheus-config', action='store_true', help=u'correct prometheus static config file for webservices, and update s3 config file')

    # ensure
    parser_ensure = subparsers.add_parser('ensure', help=u'ensure all service count match the count that you config', formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    parser_ensure.add_argument('--disable-skip', action='store_true', help=u'disable skiping service exist ec2 instance when action is start')
    parser_ensure.add_argument('--disable-adjust', action='store_true',
                               help=u"disable adjust running service on ec2 instance when action is start, 'adjust' make sure ec2 instance's cpu and memory usage less than the limit")
    parser_ensure.add_argument('--action', default="start", choices=['start', 'restart'], help=u'action to oprate the service')
    parser_ensure.add_argument('--debug', action='store_true', help=u'set logger level debug, default level is info')

    # ssh
    parser_ssh = subparsers.add_parser('ssh', help=u'ssh connecto to service instance', formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    parser_ssh.add_argument('-s', '--service', required=True, help=u'service name')

    # log
    parser_log = subparsers.add_parser('log', help=u'tail service log', formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    parser_log.add_argument('-s', '--service', required=True, help=u'service name')

    # prometheus node exporter
    parser_exporter = subparsers.add_parser('pne', help=u'deploy node exporter to all web service host', formatter_class=argparse.ArgumentDefaultsHelpFormatter)

    return parser.parse_args()


def add_filters(name, values):
    return {"Name": name, "Values": [values]}


def main():
    if len(sys.argv) == 1:
        sys.argv.append('--help')

    args = parse_args()

    log_level = 'INFO'
    aws_region = current_aws_region()
    if args.command == 'list':
        coloredlogs.install(log_level, fmt="%(message)s", logger=logger)
        config_data = parse_config_file(args.config_file)
        ServiceList(aws_region, config_data=config_data).list(args.service, by_instances=args.by_instances, byvpc=config_data.get('vpcId'), bysubnet=config_data.get('subnetId'))

        if args.correct_prometheus_config:
            ServiceList(aws_region, config_data=config_data).correct_prometheus_webservice_static_config_file()

    elif args.command == 'ssh':
        coloredlogs.install(log_level, fmt="%(message)s", logger=logger)
        config_data = parse_config_file(args.config_file)
        ServiceList(aws_region, config_data).connect(args.service)
    elif args.command == 'ensure':
        if args.debug:
            log_level = 'DEBUG'
        logger_config.config_logging(log_level=log_level)
        coloredlogs.install(log_level, fmt="%(message)s")  # , logger=logger)
        configData = parse_config_file(args.config_file)
        # pprint.pprint([configData.get('vpcId'),configData.get('subnetId'),configData.get('securityGroups')])

        service_config = parse_all_service_config(args.config_file)
        ServiceStateDisiredCheck(aws_region, service_config, adjust=not args.disable_adjust, skip_exist_service_for_start=not args.disable_skip,
                                 action=args.action, vpc=configData.get('vpcId'), subnet=configData.get('subnetId')).execute()
    elif args.command == 'log':
        pass
    elif args.command == 'pne':
        logger_config.config_logging(log_level=log_level)
        PrometheusNodeExporter(aws_region).execute()
    else:
        log_level = 'INFO'
        if args.debug:
            log_level = 'DEBUG'
        logger_config.config_logging(log_level=log_level)
        coloredlogs.install(log_level, fmt="%(message)s")  # ,logger=logger)

        config_data = parse_config_file(args.config_file)
        params = extract_service_info(config_data, args.service,
                                      count=args.count,
                                      instance_type=args.instance_type,
                                      cpu=args.cpu,
                                      memory=args.memory)

        # can not find params for args.service
        if not params:
            return

        Deployer(aws_region, args.action, params, adjust=not args.disable_adjust, skip_exist_service_for_start=not args.disable_skip).deploy(config_data.get('vpcId'), config_data.get('subnetId'))


if __name__ == '__main__':
    main()
