# -*- coding: utf-8 -*-

import boto3
import csv
import os
from boto3.dynamodb.conditions import Key, Attr
from datetime import datetime

CUR_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__)))
AWS_ACCESS_KEY_ID = os.environ.get('AWS_ACCESS_KEY_ID')
AWS_ACCESS_KEY_SECRET = os.environ.get('AWS_SECRET_ACCESS_KEY')

# Get the service resource.
dynamodbResource = boto3.resource('dynamodb', region_name='ap-northeast-2', aws_access_key_id=AWS_ACCESS_KEY_ID, aws_secret_access_key=AWS_ACCESS_KEY_SECRET)


table_now = 'prod_g1054'
table_old_829 = 'g1054_8_29'

def read_csv(fn):
    p = os.path.join(CUR_DIR, fn)
    rows = []
    with open(p, 'r') as f:
        rander = csv.DictReader(f)
        rows = [i for i in rander]
    return rows

def write_to_csv(fn, data):
    p = os.path.join(CUR_DIR, fn)
    with open(p, 'w+') as f:
        f.write('userId,gameType,jobId,times,times_829,times_now\n')
        for row in data:
            print row
            f.write('%s,%s,%s,%s,%s,%s\n' % (row['userId'], row['gameType'], row['jobId'], row['times'], row['times_829'], row['times_now']))

def query_game_data(table, sub_key, user_id):
    table = dynamodbResource.Table(table)
    res = table.query(Select='ALL_ATTRIBUTES', KeyConditionExpression=Key('userId').eq(int(user_id)) & Key('subKey').eq(sub_key))
    return res

def query_user_jobs():
    results = []

    rows = read_csv('props_g1054.csv')
    for row in rows:
        print(row)
        current = query_game_data(table_now, '1', row['userId'])
        old = query_game_data(table_old_829, '1', row['userId'])

        row['times_829'] = job_times(old, row['jobId'])
        row['times_now'] = job_times(current, row['jobId'])
        results.append(row)

    write_to_csv('props_g1054-results.csv', results)

def job_times(data, job_id):
    if data['Count'] == 0:
        return '0'
    
    k = job_id.split(':')[1]
    for item in data['Items']:
        for j in item['jobs_data']:
            if str(k) == str(j['id']):
                return str(j['times'])
    return '0'

query_user_jobs()