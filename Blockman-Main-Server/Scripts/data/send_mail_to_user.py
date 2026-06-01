import requests
import os
import csv
import hashlib
import random
import time

CUR_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__)))

URLS = {
    'SB': 'http://mods.sandboxol.com',
    'IN': 'http://indmods.sandboxol.com',
    'GARENA': 'https://service.blockmanmobile.com',
    'TEST': 'http://dev.mods.sandboxol.cn'
}

def send_mail(user, host):
    print(user)
    url = '%s/mailbox/api/v1/inner/mail/send/%s?%s'% (host, user['user_id'], generate_api_params())
    print(url)
    res = requests.post(url, json = {
        'title': 'BedWars',
        'mailId': '',
        'content': user['content'],
        'langType': 0,
    })
    print(res)
    print('----------------------')

def generate_api_params():
    secret = 'pq0194mxoqfh48L362G6R09T737E273X'
    nonce = random.randint(1000, 1000000)
    timestamp = int(time.time() * 1000)
    raw_string = '%s%d%d' % (secret, nonce, timestamp)
    sha_1 = hashlib.sha1()
    sha_1.update(raw_string.encode('utf-8'))
    signature = sha_1.hexdigest()
    return 'signature=%s&nonce=%d&timestamp=%d' % (signature, nonce, timestamp)

def get_url(user):
    r = 'SB'
    if user['region'] == 'TEST':
        r = 'TEST'
    elif user['region'] not in ('SB', 'IN', ''):
        r = 'GARENA'
    elif user['region'] == 'SB':
        r = 'SB'
    else:
        r = 'IN'
    return URLS[r]

def read_csv(fn):
    p = os.path.join(CUR_DIR, fn)
    rows = []
    with open(p, 'r') as f:
        rander = csv.DictReader(f)
        rows = [i for i in rander]
    return rows

def main():
    users = read_csv('g1008_users_001.csv')
    for user in users:
        url = get_url(user)
        send_mail(user, url)

main()


