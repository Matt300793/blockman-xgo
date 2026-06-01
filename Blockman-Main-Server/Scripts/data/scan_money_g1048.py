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

rangeMap = {
    u'0-10': (0, 10),
    u'11-50': (11, 50),
    u'51-100': (51, 100),
    u'101-200': (101, 200),
    u'201-300': (201, 300),
    u'301-400': (301, 400),
    u'401-500': (401, 500),
    u'501-600': (501, 600),
    u'601-700': (601, 700),
    u'701-800': (701, 800),
    u'801-900': (801, 900),
    u'901-1000': (901, 1000),
    u'1001-1500': (1001, 1500),
    u'1501-2500': (1501, 2500),
    u'2501-5000': (2501, 5000),
    u'5000-1亿': (5001, 100000000),
    u'1亿-2亿': (100000001, 200000000),
    u'2亿-3亿': (200000001, 300000000),
    u'3亿以上': (300000001, 100000000000000),
}

USER_MONEY = {}

def write_csv():
    print USER_MONEY
    fp = os.path.join(CUR_DIR, 'user-money.csv')
    with open(fp, 'w') as f:
        f.write('UserID,Money\n')
        for k, v in USER_MONEY.items():
            line = u'%s,%d\n' % (k, v)
            f.write(line.encode('utf8'))

def add_user_count(money):
    key = str(money)
    for k, scope in rangeMap.items():
        if scope[0] <= money and money <= scope[1]:
            key = k
            break
    USER_MONEY[key] = USER_MONEY.get(key, 0) + 1

def scan_table():
    summary = 0
    page_size = 5000
    table = dynamodbResource.Table('prod_g1048')
    res = table.scan(Limit=page_size, Select='ALL_ATTRIBUTES', FilterExpression=Attr('subKey').eq('ShareData'))
    summary += res['Count']

    print '-----------------scan count: ', res['Count'], summary
    
    process_items(res)
    while res.has_key('LastEvaluatedKey'):  
        res = table.scan(Limit=page_size, Select='ALL_ATTRIBUTES', FilterExpression=Attr('subKey').eq('ShareData'), ExclusiveStartKey=res['LastEvaluatedKey'])
        
        summary += res.get('Count', 0)
        print '-----------------scan count: ', res.get('Count'), summary

        process_items(res)
    
    print 'Process Rows:', summary

def process_items(res):
    for i in res['Items']:
        if i['subKey'] == 'ShareData':
            add_user_count(i.get('money', 0))

scan_table()
write_csv()
