#!/usr/bin/env python
# -*- coding: utf-8 -*-
import os
import sys
from datetime import datetime
from thread import start_new_thread
from task import Task
from flask import Flask
import playbook.deployer as dpl


class Service:
    def __init__(self, app, aws_region=None):
        self.app = app
        self.aws_region = aws_region
        self.log_dir = os.path.join(app.config['TINYDB_DIR'], 'tasklogs')
        
        if not os.path.exists(self.log_dir):
            os.makedirs(self.log_dir)

    def __load_config(self):
        if not self.aws_region:
            self.aws_region = dpl.current_aws_region()

        self.config_data = dpl.parse_config_file(self.app.config['SERVICE_CONFIG'])
        self.sl = dpl.ServiceList(self.aws_region, self.config_data)

    def details(self):
        self.__load_config()

        results = {}
        services, _ = self.sl.get_service_list()
        for s in services:
            if results.has_key(s['serviceName']):
                i = results[s['serviceName']]
                i['count'] += 1
            else:
                results[s['serviceName']] = {'count': 1, 'privateIp': s['privateIp'], 'serverPort': s['port'], 'metricsPort': s['metricsPort']}

        tasks = Task().get_task_data()
        for n, d in results.items():
            for t in tasks:
                if n == t['service']:
                    d['taskId'] = t['id']
                    d['taskStatus'] = t['status']
        return results, services

    def restart(self, name, ip=None):
        self.__load_config()

        params = dpl.extract_service_info(self.config_data, name)
        tid = Task(self.aws_region, 'restart', params, app=self.app).restart_service()
        print 'task started, id=', tid
        return tid

    def restart_service(self, name, ips=[], log_filepath=None, disable_update_code=True):
        self.__load_config()

        params = dpl.extract_service_info(self.config_data, name)
        now = datetime.now()
        if not log_filepath:
            log_filepath = '%s/%s_%s.log' % (self.log_dir, name, now.strftime("%Y%m%d%H%M%S"))
        params['logfile'] = log_filepath
        d = dpl.Deployer(self.aws_region, 'restart', params, disable_update_code=disable_update_code)
        stats = d.deploy(inner_ips=ips)
        return stats

    def restart_service_async(self, name, ips=[]):
        start_new_thread(self.restart_service, (name, ips, None, False))

    def log(self, logger_path):
        if os.path.exists(logger_path):
            with open(logger_path, 'r') as f:
                return f.read()
        return None
