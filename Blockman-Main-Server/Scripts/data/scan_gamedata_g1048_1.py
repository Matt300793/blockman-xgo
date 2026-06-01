import boto3
import csv
import os
from boto3.dynamodb.conditions import Key, Attr
from datetime import datetime
import requests
from decimal import Decimal

CUR_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__)))
AWS_ACCESS_KEY_ID = os.environ.get('AWS_ACCESS_KEY_ID')
AWS_ACCESS_KEY_SECRET = os.environ.get('AWS_ACCESS_KEY_SECRET')

# Get the service resource.
dynamodbResource = boto3.resource('dynamodb', region_name='ap-northeast-2', aws_access_key_id=AWS_ACCESS_KEY_ID, aws_secret_access_key=AWS_ACCESS_KEY_SECRET)

USER_ITEMS = {}
USER_MONEY = {}

disp_list = [
    'http://18.234.153.87:9902',
    'http://54.180.103.67:9902',
    'http://3.121.162.63:9902',
    'http://152.32.185.82:9902'
]

def read_csv(fn):
    p = os.path.join(CUR_DIR, fn)
    rows = []
    with open(p, 'r') as f:
        rander = csv.DictReader(f)
        rows = [i for i in rander]
    return rows

def read_user_ids():
    rows = read_csv("user_g1048_consume_top.csv")
    return rows

def process_user_data(users):
    for u in users:
        scan_user_data(u['userId'])

def process_user_money(users):
    for u in users:
        scan_user_sharedata(u['userId'])

def scan_user_sharedata(user_id):
    table = dynamodbResource.Table('prod_g1048')
    res = table.query(Select='ALL_ATTRIBUTES', KeyConditionExpression=Key('userId').eq(int(user_id)) & Key('subKey').eq('ShareData'))
    count_user_money(user_id, res)

def read_user_items(user_id):
    items = []
    table = dynamodbResource.Table('prod_g1048')
    
    res = table.query(Select='ALL_ATTRIBUTES', KeyConditionExpression=Key('userId').eq(int(user_id)))
    items.extend(res['Items'])

    while res.has_key('LastEvaluatedKey'):
        print user_id, 'next page', res['LastEvaluatedKey']
        res = table.query(Select='ALL_ATTRIBUTES', KeyConditionExpression=Key('userId').eq(int(user_id)), ExclusiveStartKey=res['LastEvaluatedKey'])
        items.extend(res['Items'])
    
    return items

def scan_user_data(user_id):
    table = dynamodbResource.Table('prod_g1048')
    res = table.query(Select='ALL_ATTRIBUTES', KeyConditionExpression=Key('userId').eq(int(user_id)))
    count_user_items(user_id, res)

def count_user_items(user_id, data):
    items = data['Items']
    try:
        for item in items:
            if item['subKey'] == 'ShareData':
                count_share_data(user_id, item)
            if item['subKey'] == 'chest':
                count_chest(user_id, item)
            if item['subKey'].endswith('v2'):
                count_block(user_id, item)
    except Exception, e:
        print 'count user data faild:', user_id, e

def count_share_data(user_id, item):
    for i in item['inventory']['item']:
        add_item(user_id, int(i['id']), int(i['num']))

def count_chest(user_id, item):
    for _, items in item['chest'].items():
        for i in items:
            add_item(user_id, int(i['id']), int(i['num']))

def count_block(user_id, item):
    for _, val in item['block'].items():
        item_id, _ = val.split(':')
        if item_id == '1422':
            add_item(user_id, int(item_id), 1)

def add_item(user_id, item_id, num):
    items = {}
    if USER_ITEMS.has_key(user_id):
        items = USER_ITEMS[user_id]
    
    items[item_id] = items.get(item_id, 0) + num

    USER_ITEMS[user_id] = items

def count_user_money(user_id, data):
    items = data['Items']
    try:
        for item in items:
            if item.has_key('money'):
                USER_MONEY[user_id] = item.get('money')
    except Exception, e:
        print 'count user money faild: ', e

def write_csv():
    headers = ['userId']
    rows = []
    for user_id, items in USER_ITEMS.items():
        row = [str(user_id)]
        for k in items.keys():
            if str(k) not in headers:
                headers.append(str(k))
        for h in headers[1:]:
            if items.has_key(int(h)):
                row.append(str(items[int(h)]))
            else:
                row.append('')
        rows.append(row)
    
    fp = os.path.join(CUR_DIR, 'user-items.csv')
    with open(fp, 'w') as f:
        f.write('%s\n' % ','.join(headers))
        for r in rows:
            f.write('%s\n' % ','.join(r))


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
                if game.get('gameType') == 'g1048':
                    print d, 'online'
                    exists = True
                break
        except Exception, e:
            print 'check user online error: ', user_id, url, params, '\n', e
            continue

    return exists

def read_unusual_user_ids():
    rows = read_csv("user_g1048_unusual_ids.csv")
    return rows

def process_user_item_to_zero(users, item_ids, to_id):
    table = dynamodbResource.Table('prod_g1048')
    onlineUsers = []
    for user in users:
        if not check_is_user_online(user['userId']):
            result = read_user_items(user['userId'])
            items = set_user_item_to_zero(result, item_ids, to_id, user['userId'])
            for i in items:
                table.put_item(Item=i)
            print user, 'success', len(items)
        else:
            onlineUsers.append(user)
            print user, 'is online'

    write_online_users(onlineUsers)

def write_online_users(users):
    fp = os.path.join(CUR_DIR, 'user_g1048_unusual_ids.csv')
    with open(fp, 'w') as f:
        f.write('userId\n')
        for u in users:
            f.write('%s\n' % u['userId'])

def set_user_item_to_zero(items, item_ids, to_id, user_id):
    results = []
    for item in items:
        subkey = item['subKey']
        if subkey == 'ShareData' and int(user_id) != 1062074208:
            results.append(set_share_data(item, item_ids, to_id))
        if subkey == 'chest':
            results.append(set_chest(item, item_ids, to_id))
        if subkey.endswith('v2'):
            results.append(set_block(item, item_ids, to_id))
    
    return results

def set_share_data(item, item_ids, to_id):
    if not item.has_key('inventory') or not item['inventory'].has_key('item'):
        return item

    for i in item['inventory']['item']:
        if i['id'] in item_ids:
            i['id'] = Decimal(to_id)

    return item

def set_chest(item, item_ids, to_id):
    if not item.has_key('chest') or type(item['chest']) == list:
        return item

    for _, items in item['chest'].items():
        for i in items:
            if i['id'] in item_ids:
                i['id'] = Decimal(to_id)

    return item

def set_block(item, item_ids, to_id):
    if not item.has_key('block'):
        return item

    for key, val in item['block'].items():
        item_id, meta = val.split(':')
        if int(item_id) in item_ids:
            item['block'][key] = str(to_id) + ':' + meta

    return item


process_user_data(read_user_ids())
write_csv()

# process_user_item_to_zero(read_unusual_user_ids(), [1422, 2422], 1)
