#!/usr/bin/env python
# encoding: utf-8

import boto3
import base64
import os
import logging
import random
DEFAULT_REGION = 'us-east-1'
from concurrent.futures import ThreadPoolExecutor, as_completed


class Ec2:
    ec2 = None
    region = None

    def __init__(self, region=DEFAULT_REGION):
        self.region = region
        print(region)
        self.ec2 = boto3.client('ec2',
                                region)

    
    def launch_instance(self, count, ima_id='', instance_type='', sgs=[],  subnet='', vpc='', tags=[], user_data='', instance_profile={}):
        if count == 1:
            return self.launch(count, ima_id, instance_type, sgs,  subnet, vpc, tags, user_data, instance_profile)
            
        results = {}
        futures = {}
        with ThreadPoolExecutor(max_workers=count) as executor:
            for i in range(count):
                futures[executor.submit(self.launch, 1, ima_id, instance_type, sgs, subnet, vpc, tags, user_data, instance_profile)] = i
            executor.shutdown(wait=True)
        
        for f, key in futures.items():
            try:
                result = f.result()
                instances = results.get('Instances')
                if instances is None:
                    instances = []
                instances.append(result['Instances'][0])
                results['Instances'] = instances
            except Exception as exc:
                print('%r generated an exception: %s' % (key, exc))
                pass
        
        return results


    def launch(self, count, ima_id='', instance_type='', sgs=[],  subnet='', vpc='', tags=[], user_data='', instance_profile={}):
        self.vpcId = vpc
        if subnet:
            self.subnet = subnet
        else:
            result = self.describe_subnets(self.vpcId)
            subnets = [i['SubnetId'] for i in result['Subnets'] if i['SubnetId'] != 'subnet-6a0c8b57']
            self.subnet = random.choice(subnets)
        instance_tags = []
        for k, v in tags.items():
            instance_tags.append({'Key': k, 'Value': v})
        result = self.ec2.run_instances(
            ImageId=ima_id,
            MinCount=count,
            MaxCount=count,
            KeyName='admin',
            InstanceType=instance_type,
            SecurityGroupIds=sgs,
            #SecurityGroups=sgs, # [EC2-Classic, default VPC] One or more security group names. For a nondefault VPC, you must use security group IDs instead.
            Monitoring={
                'Enabled': True
            },
            DisableApiTermination=False,
            InstanceInitiatedShutdownBehavior='stop',
            EbsOptimized=False,
            SubnetId=self.subnet,
            TagSpecifications=[{
                'ResourceType': 'instance',
                'Tags': instance_tags
            }],
            BlockDeviceMappings=[{
                'DeviceName': '/dev/sda1',
                'Ebs': {
                    'DeleteOnTermination': True,
                    'VolumeType': 'gp2'
                }
            }],
            UserData=user_data,
            IamInstanceProfile=instance_profile
        )

        ids = [ins['InstanceId'] for ins in result['Instances']]
        self.wait_instances_running(ids, "instance_status_ok")
        return result

    def terminate(self, ids):
        return self.ec2.terminate_instances(InstanceIds=ids)

    def find_security_groups_via_subnet(self, subnet):
        response = self.ec2.describe_subnets(SubnetIds=[subnet])
        try:
            vpc = response['Subnets'][0]['VpcId']
            result = self.describe_security_groups_by_vpc(vpc)
            return result
        except:
            return None

    def describe_security_groups_by_vpc(self, vpc):
        filters = [{'Name': 'vpc-id', 'Values': [vpc]}]
        result = self.ec2.describe_security_groups(Filters=filters)

        try:
            result = [{gn['GroupName']:gn['GroupId']} for gn in result['SecurityGroups']]
            return result
        except:
            return None

    def stop(self, ids):
        return self.ec2.stop_instances(InstanceIds=ids)

    def start(self, ids):
        return self.ec2.start_instances(InstanceIds=ids)

    def wait_instances_running(self, ids, waiter="instance_running"):
        waiter = self.ec2.get_waiter(waiter)
        waiter.wait(InstanceIds=ids)

    def describe_instances(self, instance_ids=[], filters=[]):
        result = {}
        if instance_ids and len(instance_ids) > 0:
            result = self.ec2.describe_instances(Filters=filters, InstanceIds=instance_ids)
        else:
            result = self.ec2.describe_instances(Filters=filters, MaxResults=1000)
        
        next_token = result.get('NextToken', None)
        while next_token is not None:
            next_result = self.ec2.describe_instances(Filters=filters, InstanceIds=instance_ids, MaxResults=1000, NextToken=next_token)
            next_token = next_result.get('NextToken', None)
            result = self.merge_result(result, next_result)
        return result

    def merge_result(self, result, next_result):
        def get_all_instance(data):
            instances = []
            if data.has_key('Reservations') and len(data['Reservations']) > 0:
                for r in data['Reservations']:
                    for i in r['Instances']:
                        instances.append(i)
            return instances
        
        if result.has_key('Reservations') and len(result['Reservations']) > 0:
            result['Reservations'][0]['Instances'].extend(get_all_instance(next_result))
        return result

    def create_tags(self, resource_ids, tags):
        self.ec2.create_tags(
            Resources=resource_ids,
            Tags=tags
        )

    def delete_tags(self, resource_ids, tags):
        self.ec2.delete_tags(Resources=resource_ids, Tags=tags)

    def create_security_group(self, name):
        self.ec2.create_security_group(
            DryRun=True,
            GroupName=name,
            Description='sg for %s' % name,
            #            VpcId='vpc-1d079e79'
            VpcId=self.vpcId
        )

    def get_instances_by_name(self, name):
        return self.describe_instances(filters=[
            {
                'Name': 'tag:Name',
                "Values": [name]
            }
        ])
        

    def get_instances_by_tag_key(self, key, other_filters=[]):
        filters = [
            {
                'Name': 'tag-key',
                'Values': [key]
            }
        ]
        if other_filters:
            filters.extend(other_filters)
        return self.describe_instances(filters=filters)

    def get_instances_by_tags(self, tags, other_filters=[]):
        filters = []
        for k, v in tags.items():
            filters.append({
                'Name': 'tag:%s' % k,
                'Values': [v]
            })
        if len(other_filters) > 0:
            filters.extend(other_filters)

        return self.describe_instances(filters=filters)

    def get_instances_by_private_ips(self, ips):
        return self.describe_instances(filters=[
            {
                'Name': 'private-ip-address',
                'Values': ips
            }
        ])

    def describe_subnets(self, vpc_id):
        return self.ec2.describe_subnets(Filters=[
            {
                'Name': 'vpc-id',
                'Values': [vpc_id]
            }
        ])


class LoadBlancing:
    def __init__(self, region=DEFAULT_REGION, byvpc=None, bysubnet=None):

        self.client = boto3.client('elbv2', region)

    def register_target(self, arn, id, port=None):
        target = {'Id': id}
        if port:
            target['Port'] = port

        return self.client.register_targets(
            TargetGroupArn=arn,
            Targets=[target]
        )

    def diregister_target(self, arn, id, port=None):
        target = {'Id': id}
        if port:
            target['Port'] = port

        return self.client.deregister_targets(
            TargetGroupArn=arn,
            Targets=[target]
        )

    def describe_target_health(self, arn, id=None, port=None):
        targets = []

        target = None
        if port:
            target = {'Port': port}

        if id:
            if target:
                target['Id'] = id
            else:
                target = {'Id': id}
            
        if target:
            targets = [target]

        return self.client.describe_target_health(
            TargetGroupArn=arn,
            Targets=targets
        )
