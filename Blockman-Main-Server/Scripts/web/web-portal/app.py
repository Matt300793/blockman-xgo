#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import os
import sys
import itertools
import json
import atexit
from flask import Flask, request, Response, render_template
from flask_bootstrap import Bootstrap
from flask_bootstrap import __version__ as FLASK_BOOTSTRAP_VERSION

from model import model
from manager import Service
from monitoring.monitoring import MonitorManager, ServiceData

app = Flask(__name__)
Bootstrap(app)
app.config.from_object('config')
model.init(app)

monitor_manager = MonitorManager(app)
monitor_manager.run()
monitor_manager.ensure_monitor_running_correct()
# atexit.register(lambda: monitor_manager.shutdown())


@app.route("/", methods=['GET'])
def index():
    '''
    Show all services, instances, health status, and available actions
    '''
    results = ServiceData(app).service_stats()
    results = sorted(results, key=lambda s: s['unhealthCount'], reverse=True)
    return render_template('index.html', services=results)


@app.route("/test", methods=['GET'])
def test():
    return render_template('base.html')


@app.route("/tasks/log", methods=['GET'])
def task_log():
    logger_path = request.args.get('logger_path', '')
    content = ''
    if logger_path:
        content = Service(app).log(logger_path)
    if not content:
        return render_template('not_found.html')
    content = content.replace('\n', '<br />')
    return render_template('log.html', content=content)


@app.route("/config", methods=['GET'])
def config():
    with open(app.config['SERVICE_CONFIG'], 'r') as f:
        content = f.read()
    return render_template('config.html', content=content)


################# API ###################

@app.route("/api/config", methods=['POST'])
def update_config():
    content = request.form['content']
    with open(app.config['SERVICE_CONFIG'], 'w') as f:
        f.write(content)
    return Response('OK', mimetype='plain/text')


@app.route("/api/tasks", methods=['POST'])
def task_action():
    '''
    Start a task to execute
    '''
    name = request.form['name']
    ips = []
    if 'ip' in request.form:
        ips.append(request.form.get('ip'))
    print('restart', name, ips)
    tid = Service(app).restart_service_async(name, ips)
    data = {
        'code': 1,
        'message': f'task for {name} is started, please wait a few minutes.',
        'data': {
            'taskId': tid
        }
    }
    return Response(json.dumps(data), mimetype='application/json')


@app.route("/api/tasks/<id>/status", methods=['GET'])
def task_status(id):
    return "Task status"