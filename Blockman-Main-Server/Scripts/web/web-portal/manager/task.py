#!/usr/bin/env python
# -*- coding: utf-8 -*-
import os
import sys
import datetime
import json
from thread import start_new_thread
from functools import partial
import playbook.deployer as dpl

DATA_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', 'data'))
if not os.path.exists(DATA_DIR):
    os.mkdir(DATA_DIR)

class Task:
    def __init__(self, aws_region='us-east-1', action='restart', params={}, app=None):
        self.app = app
        self.aws_region = aws_region
        self.action = action
        self.params = params

    def restart_service(self):
        t = self.__new_task_data(self.params['service'])
        self.__new_task(t)
        start_new_thread(self.__deploy, (self.aws_region, self.action, self.params, t))
        return t['id']

    def get_task_data(self):
        return self.__load_tasks()

    def get_log_content(self, task_id):
        content = None

        fp = os.path.join(DATA_DIR, 'tasklogs', task_id + '.log')
        print fp
        if not os.path.exists(fp):
            return None

        with open(fp, 'r') as f:
            content = f.read()

        return content

    def __deploy(self, aws_region, action, params, task):
        print 'deploy...', aws_region, action, params, task
        d = dpl.Deployer(aws_region, action, params)
        d.set_logger_file(task['log'], 'INFO')
        stats = d.deploy()
        print 'end...', stats
        self.__update_task(task)

    def __new_task_data(self, service):
        now = datetime.datetime.now()
        tid = '%s_%s' % (service, now.strftime("%Y%m%d%H%M%S"))
        fn = os.path.join(DATA_DIR, 'tasklogs', '%s.log' % tid)
        t = {
            'id': tid,
            'service': service,
            'log': fn,
            'status': 'running',
            'startAt': datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        }
        self.__new_task(t)
        return t

    def __new_task(self, data):
        with open(os.path.join(DATA_DIR, 'data.json'), 'r+') as f:
            content = f.read()
            if data['id'] not in content:
                f.seek(0, 0)
                f.write(json.dumps(data) + '\n' + content)

    def __update_task(self, data):
        data['endAt'] = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        data['status'] = 'finished'

        lines = []
        changed = False
        with open(os.path.join(DATA_DIR, 'data.json'), 'r+') as f:
            for l in f.readlines():
                if data['id'] in l:
                    lines.append(json.dumps(data) + '\n')
                    changed = True
                else:
                    lines.append(l)

        if changed:
            with open(os.path.join(DATA_DIR, 'data.json'), 'r+') as f:
                f.write(''.join(lines))

    def __load_tasks(self):
        tasks = []
        with open(os.path.join(DATA_DIR, 'data.json'), 'r') as f:
            line = f.readline()
            while line:
                tasks.append(json.loads(line))
                if len(tasks) > 30:
                    break
                line = f.readline()

        return tasks


class Logs:
    def __init__(self):
        pass

    def save_log(self, user_id, task_id, log, runtime, success):
        print 'save log:', user_id, task_id, runtime, success
        print log
