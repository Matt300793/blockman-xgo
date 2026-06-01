#!/usr/bin/env python
# encoding: utf-8

import sys, os
import ConfigParser
import argparse
import boto3
import datetime

AWS_ACCESS_KEY_ID = os.environ.get('AWS_ACCESS_KEY_ID')
AWS_ACCESS_KEY_SECRET = os.environ.get('AWS_SECRET_ACCESS_KEY')

AWS_ACCESS_KEY_ID='AKIA2VSKAVQ747XPTTRK'
AWS_ACCESS_KEY_SECRET='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'
dynamodbResource = boto3.resource('dynamodb', region_name='cn-northwest-1', aws_access_key_id=AWS_ACCESS_KEY_ID, aws_secret_access_key=AWS_ACCESS_KEY_SECRET)

def list_all_talbes():
    tables = []
    client = boto3.client('dynamodb', region_name="cn-northwest-1", aws_access_key_id=AWS_ACCESS_KEY_ID, aws_secret_access_key=AWS_ACCESS_KEY_SECRET)
    res = client.list_tables(Limit=100)
    for t in res.get('TableNames'):
        if t.startswith('prod'):
            tables.append(t)
    
    while res.get('LastEvaluatedTableName'):
        res = client.list_tables(Limit=100, ExclusiveStartTableName=res.get('LastEvaluatedTableName'))
        for t in res.get('TableNames'):
            tables.append(t)

    return tables

def delete_item(item):
    pass

def scan_table(table_name):
    start_time = datetime.datetime.now()

    summary = 0
    page_size = 3000
    table = dynamodbResource.Table(table_name)
    print table
    res = table.scan(Limit=page_size, Select='SPECIFIC_ATTRIBUTES', AttributesToGet=['userId', 'subKey', 'updateAt'])
    summary += res['Count']
    delete_count = 0
    print table_name, 'scan count: ', res['Count'], summary


    while res.has_key('LastEvaluatedKey'):
        for i in res['Items']:
            updateAt = datetime.datetime.strptime(i['updateAt'], '%Y-%m-%d %H:%M:%S')
            dateBefore = datetime.datetime.strptime('2020-07-30', '%Y-%m-%d')
            if updateAt < dateBefore:
                dres = table.delete_item(Key={
                    'userId': i.get('userId'),
                    'subKey': i.get('subKey')
                })
                delete_count += 1

        res = table.scan(Limit=page_size, Select='SPECIFIC_ATTRIBUTES', AttributesToGet=['userId', 'subKey', 'updateAt'], ExclusiveStartKey=res['LastEvaluatedKey'])
        summary += res['Count']
        print table_name, 'scan count: ', res['Count'], summary
        print table_name, 'delete count', delete_count

    end_time = datetime.datetime.now()
    print table_name, 'Used Time: %d seconds' % (end_time - start_time).seconds
    print table_name, 'Process Rows:', summary
    print table_name, 'delete count:', delete_count

tables = list_all_talbes()
for t in tables:
    scan_table(t)

