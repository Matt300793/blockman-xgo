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

USER_VALUES = {}
USER_ITEMS = {}


def read_csv(fn):
    p = os.path.join(CUR_DIR, 'config', fn)
    rows = []
    with open(p, 'r') as f:
        rander = csv.DictReader(f, dialect='excel-tab')
        rows = [i for i in rander]
    return rows


class ConfigData:
    def __init__(self):
        self.block = self.read_item_value_config()
        self.daoyu = self.read_daoyu_config()
        self.products = self.read_products()
        self.sitems = self.read_special_items()

    def read_item_value_config(self):
        result = {}
        rows = read_csv('items.csv')
        for i in rows:
            k = '%s:%s' % (i['id'], i['meta'])
            result[k] = int(i['value'])
        return result

    def read_daoyu_config(self):
        rows = read_csv('daoyu.csv')
        result = {}
        for i in rows:
            result[i['area']] = int(i['value'])
        return result

    def read_products(self):
        ids = ['4001', '4002', '4003']
        result = {}

        for i in ids:
            rows = read_csv('products%s.csv' % i)
            m = {}
            for r in rows:
                m[r['level']] = r['value']
            result[i] = m
        return result

    def read_special_items(self):
        rows = read_csv('specialitem.csv')
        return [r['id'] for r in rows]


configdata = ConfigData()


def process_blocks(item):
    # blocks
    block = item.get('block')
    if block and len(block) > 0:
        for b in block:
            splits = b.split(':')
            id = splits[-2]
            meta = splits[-1]

            check_blcok(str(id), str(meta), 1, item['userId'])


def check_blcok(id, meta, num, uid):
    k = '%s:%s' % (id, meta)
    if configdata.block.has_key(k):
        add_user_value(uid, configdata.block.get(k) * num)

    if str(id) in configdata.sitems:
        add_special_item(uid, id)


def add_special_item(uid, id):
    k = '%d:%s' % (uid, str(id))
    if USER_ITEMS.has_key(k):
        USER_ITEMS[k] += 1
    else:
        USER_ITEMS[k] = 1


def add_user_value(uid, val):
    if USER_VALUES.has_key(uid):
        USER_VALUES[uid] += int(val)
    else:
        USER_VALUES[uid] = int(val)


def process_sharedata(item):
    # area, products, inventory

    def foreach_block(blocks):
        for i in blocks:
            check_blcok(str(i['id']), str(i['meta']), int(i['num']), item['userId'])

    inventory = item.get('inventory', None)
    if inventory:
        foreach_block(inventory['item'])
        foreach_block(inventory['gun'])
        foreach_block(inventory['armor'])

    area = item.get('area', None)
    if area:
        val = configdata.daoyu.get(area, None)
        if val != None:
            add_user_value(item['userId'], val)
        else:
            print 'warn: can not get area value by', area, configdata.daoyu

    products = item.get('products', None)
    if products:
        for p in products:
            product = configdata.products.get(str(p['Id']), None)
            if product != None:
                val = product.get(str(p['level']), None)
                if val != None:
                    add_user_value(item['userId'], val)
                else:
                    print 'warn: can not get value by level', p['level'], p
            else:
                print 'warn: can not get product by id', p['Id']


def process_chest(item):
    # chest
    chest = item.get('chest')
    if chest:
        for v in chest.values():
            for i in v:
                check_blcok(str(i['id']), str(i['meta']), int(i['num']), item['userId'])


def calculate_user_value(item):
    sk = item['subKey']
    if sk.startswith('block'):
        process_blocks(item)
    elif sk == 'ShareData':
        process_sharedata(item)
    elif sk == 'chest':
        process_chest(item)


def scan_table():
    start_time = datetime.now()

    summary = 0
    page_size = 5000
    table = dynamodbResource.Table('prod_g1048')
    res = table.scan(Limit=page_size, Select='ALL_ATTRIBUTES')
    summary += res['Count']

    print '-----------------scan count: ', res['Count'], summary

    while res.has_key('LastEvaluatedKey'):
        for i in res['Items']:
            calculate_user_value(i)

        res = table.scan(Limit=page_size, Select='ALL_ATTRIBUTES', ExclusiveStartKey=res['LastEvaluatedKey'])
        summary += res['Count']
        print '-----------------scan count: ', res['Count'], summary

    write_csv()

    end_time = datetime.now()
    print 'Used Time: %d seconds' % (end_time - start_time).seconds
    print 'Process Rows:', summary


def write_csv():
    fp = os.path.join(CUR_DIR, 'user-values.csv')
    with open(fp, 'w') as f:
        f.write('UserID,Values\n')
        for k, v in USER_VALUES.items():
            f.write('%d,%d\n' % (k, v))

    fp = os.path.join(CUR_DIR, 'user-items.csv')
    with open(fp, 'w') as f:
        f.write('UserID,ItemID,Count\n')
        for k, v in USER_ITEMS.items():
            a = k.split(':')
            f.write('%s,%s,%d\n' % (a[0], a[1], int(v)))

# scan_table()


def clean_user_data():
    rows = read_csv("userids.csv")
    for r in rows:
        print r
        delete_user_data(r['UserID'])


def delete_user_data(userId):
    table = dynamodbResource.Table('prod_g1048')
    res = table.scan(
        Limit=100,
        Select="ALL_ATTRIBUTES",
        FilterExpression=Attr('userId').eq(userId)
    )
    items = res['Items']
    for i in items:
        print i['userId'], i['subKey']
        # table.delete_item(Key={'userId': i['userId'], 'subKey': i['subKey']})


clean_user_data()
