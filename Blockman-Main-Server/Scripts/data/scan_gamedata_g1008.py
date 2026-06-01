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


table_now = 'prod_g1008'
table_old_828 = 'g1008_8_28'
table_old_829 = 'g1008_8_29'


def is_user_level_wrong(user_id):
    data1 = query_game_data(table_now, '1', user_id)
    data2 = query_game_data(table_old_828, '1', user_id)

    def get_level(data):
        if data['Count'] > 0:
            return data['Items'][0]['level']
        else:
            return 0

    if data1['Count'] > 0 and data2['Count'] > 0:
        l1 = get_level(data1)
        l2 = get_level(data2)

        if int(l1) < int(l2):
            print user_id, l1, l2
            return True

    return False


def query_game_data(table, sub_key, user_id):
    table = dynamodbResource.Table(table)
    res = table.query(Select='ALL_ATTRIBUTES', KeyConditionExpression=Key(
        'userId').eq(int(user_id)) & Key('subKey').eq(sub_key))
    return res


def append_wrong_user_to_file(user_id):
    fp = os.path.join(CUR_DIR, 'wrong_users.csv')
    with open(fp, 'a+') as f:
        f.write('%s\n' % str(user_id))


def check_user_data(user_id):
    if is_user_level_wrong(user_id):
        append_wrong_user_to_file(user_id)


def process_items(res):
    for i in res['Items']:
        if i['userId']:
            check_user_data(i['userId'])


def scan_table():
    summary = 0
    page_size = 10000
    table = dynamodbResource.Table(table_now)
    res = table.scan(Limit=page_size, Select='ALL_ATTRIBUTES',
                     FilterExpression=Attr('subKey').eq('12'))
    summary += res['Count']

    print '-----------------scan count: ', res['Count'], summary

    process_items(res)
    while res.has_key('LastEvaluatedKey'):
        res = table.scan(Limit=page_size, Select='ALL_ATTRIBUTES', FilterExpression=Attr(
            'subKey').eq('12'), ExclusiveStartKey=res['LastEvaluatedKey'])

        summary += res.get('Count', 0)
        print '-----------------scan count: ', res.get('Count'), summary

        process_items(res)

        if summary > 1000:
            break

    print 'Process Rows:', summary

# scan_table()


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
        f.write('userId,give_count,yaoshi_count_829,yaoshi_count_now\n')
        for row in data:
            print row
            f.write('%s,%s,%s,%s\n' % (
                row['userId'], row['give_count'], row['yaoshi_count_829'], row['yaoshi_count_now']))


def query_user_yaoshi():
    results = []

    rows = read_csv('users.csv')
    for row in rows:
        print(row)
        current = query_game_data(table_now, '1', row['userId'])
        old = query_game_data(table_old_829, '1', row['userId'])

        row['yaoshi_count_829'] = old['Count'] > 0 and old['Items'][0]['yaoshi'] or 0
        row['yaoshi_count_now'] = current['Count'] > 0 and current['Items'][0]['yaoshi'] or 0
        results.append(row)

    write_to_csv('users-results.csv', results)

# query_user_yaoshi()


disp_list = [
    'http://3.86.36.237:9902',
    'http://52.78.135.236:9902',
    'http://3.125.47.216:9902',
    'http://47.57.13.172:9902',
    'http://52.66.242.44:9902',
    'http://35.171.19.48:9902',
    'http://18.195.167.183:9902',
    'http://47.242.1.24:9902'
]


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


def read_user_data(user_id, table_name):
    table = dynamodbResource.Table(table_name)
    res = table.query(Select='ALL_ATTRIBUTES',
                      KeyConditionExpression=Key('userId').eq(int(user_id)))
    if res.get('Count') == 0:
        print 'data not exist in', table_name, user_id
        return []
    return res.get('Items', [])


def recover_user_data(item):
    table = dynamodbResource.Table(table_now)
    res = table.put_item(Item=item)
    if res['ResponseMetadata'].get('HTTPStatusCode') != 200:
        print 'recover_user_data', res, '\n\n'


def backup_user_data(user_id):
    items = read_user_data(user_id, table_now)
    fp = os.path.join(CUR_DIR, 'backup', str(user_id) + '.json')
    with open(fp, 'w+') as f:
        for item in items:
            f.write(json.dumps(item, default=decimal_default) + '\n')


def decimal_default(obj):
    if isinstance(obj, decimal.Decimal):
        return float(obj)
    raise TypeError


users_need_to_recover = [
    2006531856,
    791197520,
    1798636880,
    2137922464,
    1565021680,
    31821648,
    341732496
]


def recover(table):
    for user in users_need_to_recover:
        if not check_is_user_online(user):
            items = read_user_data(user, table)
            for item in items:
                backup_user_data(user)
                print 'recover user data for', user
                recover_user_data(item)


# recover(table_old_828)

users_need_to_recover = [
    2317159824,
    2008072256,
    1072937264,
    801014688,
    570149648,
    2096966224,
    387376240,
    415138704,
    327702272,
    774321136,
    650901424,
    981941904,
    1606347808,
    1649871280,
    1056344080,
    1700858864,
    1828830464,
    935554912,
    1496084272,
    19106256,
    401322704,
    223181920,
    702635296,
    687870048,
    2434563712,
    443910352,
    1025921440,
    1081225184,
    39099888,
    200302960,
    1516800320,
    758444704,
    1504642704,
    1453099568,
    790340000,
    1907668512,
    861715056,
    1729683680,
    679065376,
    1162695792,
    641216576,
    947441136,
    1176790352,
    2325611728,
    1110152064,
    887221920,
    872901472,
    1323129408,
    1934642912,
    793036464,
    1842771232,
    1614179680,
    2346232928,
    929661504,
    604824992,
    1882369088,
    2368537296,
    1338060496,
    1890950944,
    977019232,
    1153848064,
    604975056,
    2185660032,
    696281024,
    2022091120,
    1174695744,
    1155616368,
    212579312,
    1882490096,
    15989888,
    2109031728,
    1443879024,
    1859682272,
    1311495104,
    2252801920,
    1762142736,
    865612032,
    1128278096,
    1281946480,
    1128355760,
    1626015888,
    1822861296,
    401967904,
    882254640,
    1061644016,
    2372064416,
    1424281824,
    2058197424,
    1258387344,
    887457632,
    1285175728,
    2327362144,
    947157680,
    502402304,
    2254026528,
    1366277664,
    2133431696,
    1505598816,
    2007215520,
    1227563328,
    1824016192,
    1041322112,
    1603479712,
    1925717280,
    1258344032,
    536721424,
    1504387168,
    2141049008,
    827314352,
    487804048,
    1815527152,
    1650529616,
    1313942608,
    1261110080,
    1071682592,
    1981588368,
    2047561152,
    737360592,
    1651409808,
    718731664,
    949500592,
    1519961968,
    1444421136,
    357028672,
    1838784736,
    264456592,
    1900950992,
    1449469168,
    1189575408,
    1657011776,
    1514959504,
    928357728,
    1976629808,
    1153397664,
    1890482160,
    1186121392,
    2176259040,
    1464784112,
    717123056,
    1232544192,
    2196537200,
    2423885088,
    2200143888,
    1535335280,
    1420939392,
    2397415264,
    1793295968,
    1467305744,
    1076453584,
    574096944,
    1732046960,
    1194700624,
    1381814208,
    1527106272,
    398479136,
    79964528,
    2148810016,
    403182256,
    1508800832,
    1893004288,
    2248131216,
    1942277088,
    2428838512,
    1761904560,
    1343083232,
    1771141648,
    1862121520,
    563670944,
    2357438272,
    693477296,
    2062843984,
    1314153696,
    702656896,
    626197088,
    2344905808,
    2423264976,
    1617364160,
    1126723136,
    916678896,
    2056808560,
    2018796144,
    1833572272,
    1479893856,
    2172624064,
    496361984,
    1122067856,
    976499920,
    1999184496,
    1587037312,
    908793344,
    277025008,
    1904645968,
    2270446416,
    1767739200,
    1978088576,
    1162556304,
    656389552,
    2280936320,
    1176548688,
    773948672,
    977444592,
    1730067920,
    1584814976,
    521914336,
    1974151200,
    1799140128,
    190805520,
    1776212272,
    1749647632,
    1500098080,
    1241822320,
    1993925984,
    1191965056,
    1172887328,
    667012576,
    628182688,
    1680234944,
    1081562320,
    323452288,
    2328936960,
    86029040,
    2325151600,
    2102424816,
    2084245344,
    1651910864,
    998934560,
    816971040,
    2071165376,
    1619302368,
    1434014272,
    25456496,
    1822844640,
    2145747920,
    1547814368,
    1328410416,
    336635648,
    1838768672,
    991294112,
    127048608,
    1817730064,
    1443046944
]


users_need_to_recover = [
    1732046960,
    1882490096,
    1749647632
]

# recover(table_old_829)
