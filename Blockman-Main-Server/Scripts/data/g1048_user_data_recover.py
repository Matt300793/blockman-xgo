# -*- coding: utf-8 -*-
import boto3
import csv
import os
from boto3.dynamodb.conditions import Key, Attr
from datetime import datetime
import requests

CUR_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__)))
AWS_ACCESS_KEY_ID = os.environ.get('AWS_ACCESS_KEY_ID')
AWS_ACCESS_KEY_SECRET = os.environ.get('AWS_SECRET_ACCESS_KEY')

# Get the service resource.
dynamodbResource = boto3.resource('dynamodb', region_name='ap-northeast-2', aws_access_key_id=AWS_ACCESS_KEY_ID, aws_secret_access_key=AWS_ACCESS_KEY_SECRET)
disp_list = [
    'http://18.234.153.87:9902',
    'http://54.180.103.67:9902',
    'http://3.121.162.63:9902'
]


def read_csv(fn):
    p = os.path.join(CUR_DIR, 'data', fn)
    rows = []
    with open(p, 'r') as f:
        rander = csv.DictReader(f)
        rows = [i for i in rander]
    return rows


def read_user_data(user_id, date):
    table_name = 'g1048_9_21' #% date
    table = dynamodbResource.Table(table_name)
    res = table.query(Select='ALL_ATTRIBUTES', KeyConditionExpression=Key('userId').eq(int(user_id)))
    if res.get('Count') == 0:
        print 'data not exist in', table_name, user_id, date
        return []
    return res.get('Items', [])


def recover_user_data(item):
    table = dynamodbResource.Table('prod_g1048')
    res = table.put_item(Item=item)
    if res['ResponseMetadata'].get('HTTPStatusCode') != 200:
        print 'recover_user_data', res, '\n\n'


def clear_user_data(user):
    print 'clean user data', user
    table = dynamodbResource.Table('prod_g1048')
    res = table.query(Select='ALL_ATTRIBUTES', KeyConditionExpression=Key('userId').eq(int(user['user_id'])))
    for i in res.get('Items', []):
        res1 = table.delete_item(Key={'userId': i.get('userId'), 'subKey': i.get('subKey')})
        if res1['ResponseMetadata'].get('HTTPStatusCode') != 200:
            print 'clear_user_data', res1, '\n\n'


def check_is_user_online(user_id):
    url_path = '/v1/search-user'
    params = {'query': user_id}
    headers = {
        'X-Shahe-Timestamp': '1499049522339',
        'X-Shahe-Nonce': '154719',
        'X-Shahe-Signature': '88df1aad4acf445c1a396caf15fd8c0a24ad5725',
        'Content-Type': 'application/json'
    }
    exists = False
    for d in disp_list:
        url = d + url_path
        try:
            res = requests.get(url, params, headers=headers)
            if res.status_code != 200:
                print d, res.status_code, res.json()
                continue

            data = res.json()
            if data.get('code', 0) == 1:
                game = data.get('game')
                if game.get('gameType') == 'g1048' and game.get('engineVersion') == 10051:
                    print data
                    exists = True
                break
        except Exception, e:
            print 'check user online error: ', user_id, url, params, '\n', e
            continue

    return exists


def write_online_users(user):
    p = os.path.join(CUR_DIR, 'data', 'online.csv')
    with open(p, 'a') as f:
        f.write('%s,%s\n' % (u['user_id'], u['date']))


if __name__ == "__main__":
    users = [{'user_id': 808557888, 'date': 23}]  # read_csv('users.csv')
    count = 0
    for u in users:
        if not check_is_user_online(u['user_id']):
            items = read_user_data(u['user_id'], u['date'])
            if len(items) == 0:
                clear_user_data(u)
            else:
                for i in items:
                    recover_user_data(i)
        else:
            write_online_users(u)
            print u, 'is online'

        count += 1
        print count, u
