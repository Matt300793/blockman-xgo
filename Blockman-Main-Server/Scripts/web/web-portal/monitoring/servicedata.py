import os
import collections
import threading
from manager.service import Service
from tinydb import TinyDB, Query

LOCK = threading.Lock()


class ServiceData:

    def __init__(self, app):
        self.app = app
        self.db = TinyDB(os.path.join(app.config['TINYDB_DIR'], 'db.json'))
        self.service_table = self.db.table('service_data', cache_size=50)
        self.service_retire_table = self.db.table('service_retire', cache_size=10)

    def all(self):
        return self.service_table.all()

    def service_stats(self):
        services = self.all()
        results = {}
        for s in services:
            if s.has_key('serviceName') and results.has_key(s['serviceName']):
                i = results[s['serviceName']]
                i['count'] += 1

                if s.get('serviceStatus', '') == 'health':
                    i['healthCount'] += 1
                if s.get('serviceStatus', '') == 'unhealth':
                    i['unhealthCount'] += 1
                i['instances'].append(s)
            else:
                i = {'id': s['id'], 'name': s['serviceName'], 'count': 1, 'healthCount': 0, 'unhealthCount': 0, 'instances': [s], 'serverPort': s['port'], 'metricsPort': s['metricsPort']}
                if s.get('serviceStatus', '') == 'health':
                    i['healthCount'] += 1
                else:
                    i['unhealthCount'] += 1
                results[s['serviceName']] = i
        return results.values()

    def fetch_service_data(self):
        _, services = Service(self.app).details()
        for s in services:
            doc = self.find_by_id(s['id'])
            if doc:
                self.update(s, doc_ids=[doc.doc_id])
            else:
                self.insert(s)

        self.__check_not_exist_service(services)

    def __check_not_exist_service(self, services):
        results = []
        docs = self.all()
        for d in docs:
            found = False
            for s in services:
                if d['id'] == s['id']:
                    found = True
            if not found:
                results.append(d)
        if len(results) > 0:
            self.delete([i.doc_id for i in results])
            self.service_retire_table.insert_multiple(results)

    def find_by_id(self, id):
        query = Query()
        return self.service_table.get(query.id == id)

    def find_by_service(self, service_name):
        query = Query()
        return self.service_table.search(query.serviceName == service_name)

    def find_by_ip(self, ip):
        query = Query()
        return self.service_table.search(query.innerIp == ip)

    def insert(self, doc):
        LOCK.acquire()
        self.service_table.insert(doc)
        LOCK.release()

    def update(self, values, doc_ids):
        LOCK.acquire()
        result = self.service_table.update(values, doc_ids=doc_ids)
        LOCK.release()
        return result

    def delete(self, doc_ids):
        LOCK.acquire()
        result = self.service_table.remove(doc_ids)
        LOCK.release()
        return result
