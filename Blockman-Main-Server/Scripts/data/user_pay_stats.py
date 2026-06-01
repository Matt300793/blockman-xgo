# -*- coding: utf-8 -*-

import csv
import os

CUR_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__)))
COUNTRIES = ['BR', 'RU', 'VN', 'MX', 'TR', 'ID', 'PH', 'AR', 'US', 'UA', 'TH', 'CL', 'CO']
names = {
    'BR': r'巴西',
    'RU': r'俄罗斯',
    'VN': r'越南',
    'MX': r'墨西哥',
    'TR': r'土耳其',
    'ID': r'印度尼西亚',
    'PH': r'菲律宾',
    'AR': r'阿根廷',
    'US': r'美国',
    'UA': r'乌克兰',
    'TH': r'泰国',
    'CL': r'智利',
    'CO': r'哥伦比亚'
}
def read_csv(fn):
    p = os.path.join(CUR_DIR, fn)
    rows = []
    with open(p, 'r') as f:
        rander = csv.DictReader(f)
        rows = [i for i in rander]
    return rows

def write_csv(fn, headers, data):
    with open(fn, 'w') as csvfile:
        writer = csv.DictWriter(csvfile, fieldnames=headers)
        writer.writeheader()

        for row in data:
            if row[r'国家'] in COUNTRIES:
                row[r'国家'] = names[row[r'国家']]
                writer.writerow(row)
        for row in data:
            if row[r'国家'] not in COUNTRIES and row[r'国家'] not in names.values():
                writer.writerow(row)


def calculate():
    actives = {}

    paydata = read_csv('paystats.csv')
    for m in ['02', '03', '04', '05', '06']:
        content = read_csv(m + '.csv')
        rows = []
        for r in content:
            for p in paydata:
                data = {}
                if p['country'] == r['country'] and int(p['month']) == int(r['month']):
                    data['国家'] = r['country']
                    data['月份'] = r['month']
                    data['月活'] = r['num']
                    data['付费用户数'] = p['num']
                    data['付费总金额'] = p['money']
                    data['arpu'] = float(p['num']) / float(r['num']) if float(r['num']) != 0 else 0
                    data['付费率'] = float(p['money']) / float(r['num']) if float(r['num']) != 0 else 0
                    rows.append(data)
                    break
        actives[m] = rows

    for k, v in actives.items():
        print('write', k, v)
        write_csv(f'test-{k}.csv', ['国家', '月份', '月活', '付费用户数', '付费总金额', 'arpu', '付费率'], v)

calculate()

