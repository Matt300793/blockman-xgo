# -*- coding: utf-8 -*-

import os
import csv
import sys
import io
import json

sys.stdout = io.TextIOWrapper(sys.stdout.buffer,encoding='gb18030')   

CUR_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__)))

def read_csv(fn):
    p = os.path.join(CUR_DIR, fn)
    rows = []
    with open(p, 'r', encoding='utf-8') as f:
        rander = csv.DictReader(f)
        rows = [i for i in rander]
    return rows

filter_dates = ['Sep 16, 2020', 'Sep 17, 2020'] # , 'Sep 18, 2020', 'Sep 19, 2020', 'Sep 20, 2020']
counts = {}
for r in read_csv('PlayApps_202009.csv'):
    if r['Product id'] == 'com.sandboxol.blockymods':
        if len(filter_dates) > 0 and r['Transaction Date'] not in filter_dates:
            continue

        d = counts.get(r['Transaction Date'], {})
        if r['Transaction Type'] == 'Charge':
            d[r['Sku Id']] = d.get(r['Sku Id'], 0) + 1
        
        # if r['Transaction Type'] == 'Charge refund':
        #     d[r['Sku Id']] = d.get(r['Sku Id'], 0) - 1

        counts[r['Transaction Date']] = d

print(json.dumps(counts, indent='  '))

summary = {}

for k, item in counts.items():
    total = 0.0
    for p, c in item.items():
        summary[p] = summary.get(p, 0) + c
        if p == 'game.bedwar.super.player':
            total += 0.99 * c
        elif p == 'and.vip.1.1':
            total += 0.99 * c 
        elif p == 'and.vip.1.12':
            total += 10.99 * c 
        elif p == 'and.vip.2.1':
            total += 4.99 * c 
        elif p == 'and.vip.2.12':
            total += 49.99 * c 
        elif p == 'and.vip.3.1':
            total += 11.99 * c 
        elif p == 'and.vip.3.12':
            total += 89.99 * c 
        else:
            total += (int(p.split('.')[-1]) - 0.01) * c

    print(k, total)

print(json.dumps(summary, indent='  '))