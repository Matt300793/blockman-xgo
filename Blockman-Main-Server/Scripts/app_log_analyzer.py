import Levenshtein
import sys
import re
import json
import requests

class LogGroup:
    name = ''
    summary = ''
    logs = None

    def __init__(self, name, summary):
        self.name = name
        self.summary = summary
        self.logs = []

    def add(self, log):
        self.logs.append(log)

    def __str__(self) -> str:
        return 

class Log:
    service = None
    time = None
    level = None
    process_id = None
    thread_name = None
    logger_name = None
    message = None
    content = None

    def __str__(self) -> str:
        return json.dumps({
            'service': self.service,
            'time': self.time,
            'level': self.level,
            'process_id': self.process_id,
            'thread_name': self.thread_name,
            'logger_name': self.logger_name,
            'message': self.message,
            'content': self.content
        }, sort_keys=True, indent=2)

class LogGroupList:
    groups = {}

    def add_log(self, log):
        # print('add log: ', log)
        self.add_log_to_group(log)
        self.send_to_server(log)

    def send_to_server(self, log):
        playload = json.loads(str(log))
        r = requests.post('http://localhost:5000/javalogs/api/logs/event', json=playload)
        print(r.text)

    def add_log_to_group(self, log):
        g = self.get_group_or_create(log)
        g.add(log)
        self.groups[g.name] = g
    
    def get_group_or_create(self, log):
        current = sys.maxsize

        group = None
        for _, g in self.groups.items():
            dis = Levenshtein.distance(g.name, log.message)
            print(dis, g.name, '=====', log.message)
            if dis > 40:
                continue

            if dis < current:
                group = g

        if not group:
            group = LogGroup(log.message, log.content)
            group.add(log)
        return group

def read_log_file(logpath):
    groups = LogGroupList()

    last_log = None
    with open(logpath, 'r', encoding='UTF-8') as f:
        count = 0
        while True:
            line = f.readline()
            if not line:
                break

            log = extract_log(line)
            if log:
                if not last_log:
                    last_log = log
                    continue

                last_log.service = logpath
                groups.add_log(last_log)
                last_log = log
            else:
                last_log.content += line + '\n'

            count += 1
    return groups

def extract_log(log_line):
    REGEX = r'^(?P<time>.*?)\s(?P<level>\S+)\s(?P<process_id>\S+)\s---\s(?P<thread_name>\[.*?\])\s(?P<logger_name>.*?)\s+:\s(?P<message>.*?)$'
    match = re.search(REGEX, log_line)
    if not match:
        return None

    log = Log()
    log.time = match.group('time')
    log.level = match.group('level')
    log.process_id = match.group('process_id')
    log.thread_name = match.group('thread_name')
    log.logger_name = match.group('logger_name')
    log.message = match.group('message')
    log.content = log_line
    return log

groupList = read_log_file('user-service.log')
print(len(groupList.groups))