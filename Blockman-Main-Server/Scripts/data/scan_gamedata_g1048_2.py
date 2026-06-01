# -*- coding: utf-8 -*-

import boto3
import csv
import os
from boto3.dynamodb.conditions import Key, Attr
from datetime import datetime
import requests
import decimal
import json

CUR_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__)))
AWS_ACCESS_KEY_ID = os.environ.get('AWS_ACCESS_KEY_ID')
AWS_ACCESS_KEY_SECRET = os.environ.get('AWS_SECRET_ACCESS_KEY')

# Get the service resource.
dynamodbResource = boto3.resource('dynamodb', region_name='ap-northeast-2', aws_access_key_id=AWS_ACCESS_KEY_ID,
                                  aws_secret_access_key=AWS_ACCESS_KEY_SECRET)


table_now = 'prod_g1048'
table_old_829 = 'g1048_8_29'


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
        f.write('user_id,game_id,props_id,count,money_829,money_now\n')
        for row in data:
            f.write('%s,%s,%s,%s,%s,%s\n' % (
                row['user_id'], row['game_id'], row['props_id'], row['count'], row.get('Currency_829', '0'), row.get('Currency_now', '0')))


def query_game_data(table, sub_key, user_id):
    table = dynamodbResource.Table(table)
    res = table.query(Select='ALL_ATTRIBUTES', KeyConditionExpression=Key(
        'userId').eq(int(user_id)) & Key('subKey').eq(sub_key))
    return res


def job_times(data, row, kk):
    if data['Count'] == 0:
        return row

    k = row['props_id'].split(':')[0]
    for item in data['Items']:
        if k == 'YaoShi':
            row[k+kk] = str(item['yaoshi'])
        elif k == 'Currency':
            row[k+kk] = str(item['money'])

    return row


def query_user_yaoshi():
    results = []

    rows = read_csv('user_g1048.csv')
    for row in rows:
        print(row)
        current = query_game_data(table_now, 'ShareData', row['user_id'])
        old = query_game_data(table_old_829, 'ShareData', row['user_id'])
        
        row = job_times(old, row, '_829')
        row = job_times(current, row, '_now')
        results.append(row)

    write_to_csv('user_g1048-results.csv', results)


query_user_yaoshi()
