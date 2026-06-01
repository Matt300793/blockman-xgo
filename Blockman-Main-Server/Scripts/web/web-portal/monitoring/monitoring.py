import os
import collections
from apscheduler.schedulers.background import BackgroundScheduler
from servicedata import ServiceData
import requests
from datetime import datetime
from thread import start_new_thread
import copy
from manager.service import Service

MonitorManager_Running = False

class MonitorManager:
    monitor_list = None

    def __init__(self, app):
        self.app = app
        self.service_data = ServiceData(app)
        self.schedule = BackgroundScheduler(timezone='Asia/Shanghai')

    def run(self):
        global MonitorManager_Running
        if MonitorManager_Running:
            return

        print 'MonitorManager run'
        self.schedule.add_job(self.ensure_monitor_running_correct, trigger='interval', seconds=120)
        self.schedule.start()

        MonitorManager_Running = True

    def update_service_data(self):
        self.service_data.fetch_service_data()
        return self.service_data.all()

    def ensure_monitor_running_correct(self):
        services = self.update_service_data()
        groups = self.group_by(services, 'serviceName')
        if not self.monitor_list:
            self.monitor_list = MonitorList(self.app, groups)
            self.monitor_list.start_all()
        else:
            self.monitor_list.update(groups)

    def group_by(self, services, field):
        groups = {}
        for s in services:
            service_name = 'unknown'
            if s.has_key(field):
                service_name = s[field]
            if groups.has_key(service_name):
                groups[service_name].append(s)
            else:
                groups[service_name] = [s]
        return groups

    def shutdown(self):
        if self.schedule:
            self.schedule.shutdown()
        if self.monitor_list:
            self.monitor_list.shutdown()


class MonitorList:
    items = {}

    def __init__(self, app, service_groups):
        self.app = app
        self.service_groups = service_groups
        self.start_all()

    def update(self, service_groups):
        self.service_groups = service_groups
        self.start_all()

    def start_all(self):
        for k, v in self.service_groups.items():
            if not self.items.has_key(k):
                if k == 'eureka-service':
                    continue
                m = Monitor(self.app, k, list(v))
                m.run()
                self.items[k] = m
            else:
                self.items[k].update(list(v))

    def restart(self, service_name):
        if self.items.has_key(service_name):
            self.items.get(service_name).restart()

    def stop(self, service_name):
        if self.items.has_key(service_name):
            self.items.get(service_name).stop()
            del self.items[service_name]

    def all(self):
        services = []
        for _, m in self.items.items():
            services.append(m.details())
        return services

    def shutdown(self):
        for _, m in self.items.items():
            m.shutdown()


class Monitor:

    restart_records = {}

    def __init__(self, app, service_name, service_instances):
        self.app = app
        self.service_data = ServiceData(app)
        self.service_name = service_name
        self.service_instances = service_instances
        self.schedule = BackgroundScheduler(timezone='Asia/Shanghai')
        self.log_dir = os.path.join(app.config['TINYDB_DIR'], 'tasklogs')

    def details(self):
        return {
            'serviceName': self.service_name,
            'instnaces': self.service_instances
        }

    def run(self):
        if not self.service_instances or len(self.service_instances) == 0:
            return
        
        for i in self.service_instances:
            if i.get('serviceStatus', '') == 'restarting':
                i['serviceStatus'] = 'health'
                i['unhealthCount'] = 0
                self.service_data.update({'serviceStatus': 'unhealth'}, doc_ids=[i.doc_id])

        self.schedule.add_job(self.__monitoring, trigger='interval', seconds=30)
        self.schedule.start()

    def update(self, service_instances):
        new_data = []
        for i in service_instances:
            found = False
            for j in self.service_instances:
                if i['id'] == j['id']:
                    found = True
                    j = update_dict(j, i)
                    new_data.append(j)
            if not found:
                new_data.append(i)

        self.service_instances = new_data

    def __monitoring(self):
        unhealthServices = []
        service_instances = []

        for i in copy.deepcopy(self.service_instances):
            if i.get('serviceStatus', '') == 'restarting':
                print 'skiping monitoring ', i
                service_instances.append(i)
                continue

            ins = self.__check_health(i)
            self.service_data.update({
                'serviceStatus': ins.get('serviceStatus', 'health'),
                'healthCount': ins.get('healthCount', 0),
                'unhealthCount': ins.get('unhealthCount', 0)
            }, [ins.doc_id])

            if ins.get('serviceStatus', '') == 'unhealth' and ins.get('unhealthCount') >=5 and not self.__in_cool_time(ins['id']):
                now = datetime.now()
                log_filepath = '%s/%s_%s.log' % (self.log_dir, self.service_name, now.strftime("%Y%m%d%H%M%S"))
                ins['serviceStatus'] = 'restarting'
                ins['logFilepath'] = log_filepath
                self.service_data.update({
                    'logFilepath': ins['logFilepath'],
                    'serviceStatus': ins['serviceStatus']
                }, doc_ids=[ins.doc_id])

                unhealthServices.append(ins)
            
            service_instances.append(ins)
        
        if len(unhealthServices) > 0:
            print 'monitoring restart unhelath services: ', unhealthServices
            start_new_thread(self.__restart_service, (unhealthServices, log_filepath))

        self.service_instances = service_instances

    def __check_health(self, instance):
        url = 'http://%s:%s/actuator/health' % (instance['privateIp'], instance['metricsPort'])
        res = None
        data = {}
        try:
            res = requests.get(url, timeout=5)
            data = res.json()
        except Exception as e:
            print e

        if res and res.status_code == 200 and data.get('status', '') == 'UP':
            instance['healthCount'] = instance.get('healthCount', 0) + 1
            if instance['healthCount'] >= 3:
                instance['serviceStatus'] = 'health'
            instance['unhealthCount'] = 0
        else:
            instance['unhealthCount'] = instance.get('unhealthCount', 0) + 1
            if instance['unhealthCount'] >= 5:
                instance['serviceStatus'] = 'unhealth'
            instance['healthCount'] = 0

        return instance

    def __restart_service(self, instances, log_filepath):
        print 'restart service: ', self.service_name
        stats = Service(self.app).restart_service(self.service_name, [i['privateIp'] for i in instances], log_filepath=log_filepath)
        print '__restart_service result', stats

        run_success = True
        if stats:
            hosts = sorted(stats.processed.keys())
            for h in hosts:
                t = stats.summarize(h)
                print h, t
                if t['unreachable'] > 0 or t['failures'] > 0:
                    run_success = False

        for i in instances:
            if run_success:
                self.restart_records[i['id']] = {'endAt': datetime.now()}
                i['serviceStatus'] = 'restarted'
                self.service_data.update({'serviceStatus': 'restarted'}, doc_ids=[i.doc_id])
            else:
                del self.restart_records[i['id']]
                i['serviceStatus'] = 'unhealth'
                self.service_data.update({'serviceStatus': 'unhealth'}, doc_ids=[i.doc_id])

            for j in self.service_instances:
                if i['id'] == j['id']:
                    j['serviceStatus'] = i['serviceStatus']

    def __in_cool_time(self, id):
        if self.restart_records.has_key(id):
            last_end_at = self.restart_records[id]['endAt']
            print last_end_at
            duration = datetime.now() - last_end_at
            if duration.seconds < 90:
                return True
        return False

    def shutdown(self):
        if self.schedule:
            self.schedule.shutdown()


def update_dict(d, u):
    for k, v in u.iteritems():
        if isinstance(v, collections.Mapping):
            d[k] = update_dict(d.get(k, {}), v)
        else:
            d[k] = v
    return d
