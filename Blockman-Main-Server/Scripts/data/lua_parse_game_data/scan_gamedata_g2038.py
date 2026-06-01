import boto3
import csv
import os
from boto3.dynamodb.conditions import Key, Attr
from datetime import datetime
import json
import decimal
import argparse
import sys

CUR_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__)))
AWS_ACCESS_KEY_ID = os.environ.get('AWS_ACCESS_KEY_ID')
AWS_ACCESS_KEY_SECRET = os.environ.get('AWS_SECRET_ACCESS_KEY')

# Get the service resource.
dynamodbResource = boto3.resource('dynamodb', region_name='ap-northeast-2', aws_access_key_id=AWS_ACCESS_KEY_ID, aws_secret_access_key=AWS_ACCESS_KEY_SECRET)

def scan_table():
    start_time = datetime.now()

    summary = 0
    page_size = 100
    table = dynamodbResource.Table('prod_g1057')
    res = table.scan(Limit=page_size, Select='ALL_ATTRIBUTES')
    summary += res['Count']

    print '-----------------scan count: ', res['Count'], summary

    first_line = True
    while res.has_key('LastEvaluatedKey'):
        for i in res['Items']:
            if check_towerlist_ok(i):
                [level, hall_gold, cur_exp] = get_user_info(i.get('userId'))

                write_csv(i.get('userId'), level, hall_gold, cur_exp, i, first_line)
                first_line = False

        res = table.scan(Limit=page_size, Select='ALL_ATTRIBUTES', ExclusiveStartKey=res['LastEvaluatedKey'])
        summary += res['Count']
        print '-----------------scan count: ', res['Count'], summary

    end_time = datetime.now()
    print 'Used Time: %d seconds' % (end_time - start_time).seconds
    print 'Process Rows:', summary

def parse_base64_data(item):
    if item['data']:
        

def check_conditions(item):


def check_towerlist_ok(item):
    if item['subKey'] == '4':
        towerlist = item.get('towerList', [])
        for i in towerlist:
            if i.get('isHave', False) and i.get('towerId', 0) >= 402:
                return True

    return False

def get_user_info(user_id):
    table = dynamodbResource.Table('prod_g1057')
    res = table.query(Limit=1000, Select='ALL_ATTRIBUTES', KeyConditionExpression=Key("userId").eq(int(user_id)) & Key('subKey').eq('1'))
    items = res.get('Items', [])
    if len(items) > 0:
        data = items[0]
        return data.get('level'), data.get('hall_gold'), data.get('cur_exp')
    return '', '', ''

def write_csv(user_id, level, hall_gold, cur_exp, data, first_line):
    fp = os.path.join(CUR_DIR, 'user-g1057.csv')
    
    if first_line:
        with open(fp, 'w+') as f:
            if len(f.readlines()) == 0:
                f.write('user_id,level,hall_gold,cur_exp,subkey_4_data\n')

    f = open(fp, 'a')
    f.write('%s,%s,%s,%s,"%s"\n' % (user_id, level, hall_gold, cur_exp, json.dumps(data, default=decimal_default)))
    f.close()

def decimal_default(obj):
    if isinstance(obj, decimal.Decimal):
        return float(obj)
    raise TypeError

scan_table()


def parse_args():
    description = u'Query dynamodb game data for engine v2 base64 encode value'
    parser = argparse.ArgumentParser(description=description)

    parser.add_argument('-g', '--game', required=True, help=u'game type')
    parser.add_argument('-u', '--user', required=True, help=u'user id')
    parser.add_argument('-k', '--sub-key', required=True, help=u'subkey')

    return parser.parse_args()


def main():
    if len(sys.argv) == 1:
        sys.argv.append('--help')

    args = parse_args()
    query_game_data(args.game, args.sub_key, args.user)

if __name__ == "__main__":
    main()