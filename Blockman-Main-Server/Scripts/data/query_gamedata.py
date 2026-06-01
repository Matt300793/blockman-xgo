import traceback
import boto3
import csv
import os
import argparse
import sys
import json
import decimal
from boto3.dynamodb.conditions import Key, Attr
from datetime import datetime
import concurrent.futures
import threading

CUR_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__)))
AWS_ACCESS_KEY_ID = os.environ.get('AWS_ACCESS_KEY_ID')
AWS_ACCESS_KEY_SECRET = os.environ.get('AWS_SECRET_ACCESS_KEY')

AWS_ACCESS_KEY_ID='AKIASMGNM5GFIZXC4ZWM'
AWS_ACCESS_KEY_SECRET='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'

RUN_DATETIME = datetime.now().strftime('%Y%m%d%H%M%S')
_lock = threading.Lock()

# Get the service resource.
resource_map = {
    'IN': boto3.resource('dynamodb', region_name='ap-south-1', aws_access_key_id=AWS_ACCESS_KEY_ID, aws_secret_access_key=AWS_ACCESS_KEY_SECRET),
    'SB': boto3.resource('dynamodb', region_name='ap-northeast-2', aws_access_key_id=AWS_ACCESS_KEY_ID, aws_secret_access_key=AWS_ACCESS_KEY_SECRET),
    'garena': boto3.resource('dynamodb', region_name='us-east-1', aws_access_key_id='AKIAUR2KFP2DXXQ4IFE6', aws_secret_access_key='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')
}

def query_game_data(table, sub_key, user_id, region):
    dt = resource_map[region].Table(table)
    if sub_key:
        res = dt.query(Limit=1000, Select='ALL_ATTRIBUTES', KeyConditionExpression=Key("userId").eq(int(user_id)) & Key('subKey').begins_with(sub_key))
    else:
        res = dt.query(Select='ALL_ATTRIBUTES', KeyConditionExpression=Key('userId').eq(int(user_id)))

    outfile = '%s-%s-%s-%s.json' % (table, user_id, sub_key, region)

    folder = os.path.join(CUR_DIR, 'backup', table)
    if not os.path.exists(folder):
        os.mkdir(folder)
    of = os.path.join(folder, outfile)
    write_to(of, res)
    return user_id, res['Items']

def query_game_data_for_users(table, sub_key, input_file, fields, region):
    users = read_users_from_file(input_file)
    append_to(u'%s_license_%s.csv' % (table, region), 'user_id,datetime,region,prop_id,license_buy\n')
    for user in users:
        _, items = query_game_data(table, sub_key, user['user_id'])

        for item in items:
            if user['region'] != region:
                continue

            for field in fields:
                # print(field, user, item)
                # line = 'user_id: %s       license_buy:%d\n' % (user['user_id'], item[field])
                line = '%s,%s,%s,%s,%d\n' % (user['user_id'], user['datetime'], user['region'], user['prop_id'], item[field])
                print(line)
                append_to(u'%s_license_%s.csv' % (table, region), line)

def query_game_data_for_user(user, table, sub_key, fields, region):
    line = ''
    _, items = query_game_data(table, sub_key, user['user_id'], region)
    for item in items:
        for field in fields:
            line = '%s,%s,%s,%s,%d\n' % (user['user_id'], user['datetime'], user['region'], user['prop_id'], item[field])
            print(line[:-1])
            append_to(u'%s_license_%s_%s.csv' % (table, region, RUN_DATETIME), line)
    return line

def qeury_game_data_for_users_batch(table, sub_key, input_file, fields, region):
    users = read_users_from_file(input_file)
    append_to(u'%s_license_%s_%s.csv' % (table, region, RUN_DATETIME), 'user_id,datetime,region,prop_id,license_buy\n')

    users = filter_users_by_region(users, region)

    with concurrent.futures.ThreadPoolExecutor(max_workers=400) as executor:
        future_to_table = {executor.submit(query_game_data_for_user, user, table, sub_key, fields, region): user for user in users}
        for future in concurrent.futures.as_completed(future_to_table):
            schema_exe = future_to_table[future]
            try:
                data = future.result()
            except Exception as exc:
                print(u'[Worker] %r generated an exception: %s' % (schema_exe, exc))
                print(traceback.format_exc())
    concurrent.futures.wait(future_to_table)

def filter_users_by_region(users, region):
    if region != 'garena':
        users = [u for u in users if u['region'] == region]
    else:
        users = [u for u in users if u['region'] not in ('SB', 'IN', '')]
    return users

def read_users_from_file(f):
    return read_csv(f)

def read_csv(fn):
    p = os.path.join(CUR_DIR, fn)
    rows = []
    with open(p, 'r') as f:
        rander = csv.DictReader(f)
        rows = [i for i in rander]
    return rows

def append_to(file, line):
    with _lock:
        with open(file, 'a+') as f:
            f.write(line)

def write_to(file, data):
    with open(file, 'w') as f:
        f.write(json.dumps(data, indent=2, sort_keys=True, default=decimal_default))

def decimal_default(obj):
    if isinstance(obj, decimal.Decimal):
        return float(obj)
    raise TypeError

def parse_args():
    description = u'Query dynamodb game data'
    parser = argparse.ArgumentParser(description=description)

    parser.add_argument('-t', '--table', required=True, help=u'table name')
    parser.add_argument('-k', '--sub-key', required=False, help=u'subkey')
    parser.add_argument('-u', '--user', required=False, help=u'user id')
    parser.add_argument('-i', '--input-file', required=False, help=u'用户列表输入文件')
    parser.add_argument('-e', '--extract-fields', required=False, help=u'需要提取的字段列表,多个字段使用逗号隔开')
    parser.add_argument('-r', '--region', required=True, help=u'区')

    return parser.parse_args()


def main():
    if len(sys.argv) == 1:
        sys.argv.append('--help')

    args = parse_args()
    if args.input_file:
        qeury_game_data_for_users_batch(args.table, args.sub_key, args.input_file, args.extract_fields.split(','), args.region)
    else:
        if not args.user:
            print(u"请指定一个用户id或者使用输入文件参数")
        else:
            query_game_data(args.table, args.sub_key, args.user, args.region)

if __name__ == "__main__":
    main()
