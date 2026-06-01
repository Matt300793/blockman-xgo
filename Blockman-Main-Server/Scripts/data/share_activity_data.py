# -*- coding: utf-8 -*-

import MySQLdb

# conn = MySQLdb.connect(host='localhost', user='root', passwd='1', db='activitydb', port=3306)
conn = MySQLdb.connect(host='bmg-db-message-cluster.cluster-ro-ctwqdkzusa7e.us-east-1.rds.amazonaws.com', user='sandbox', passwd='sbshenqi:64', db='activitydb', port=3306)
cursor = conn.cursor()

SQLS = [
    (u'参与活动人数', 'select date(create_time) as date, count(user_id) as number from invite_new_user group by date(create_time)'),
    (u'成功邀请新用户的用户数', 'select date(create_time) as date, count(user_id) as number from invite_new_user where progress > 0 group by date(create_time)'),
    (u'邀请记录数', 'select date(create_time) as date, count(id) as number from invite_new_user_record group by date(create_time)'),
    (u'有效邀请记录数', 'select date(create_time) as date, count(id) as number from invite_new_user_record where progress > 0 group by date(create_time)'),
    (u'完成活动人数', 'select date(create_time) as date, count(user_id) as number from invite_new_user where progress = 100 group by date(create_time)'),
]

def get_data():
    results = []
    for k, v in SQLS:
        res = execute_sql(v)
        results.append((k, res))

    rows = merge_data(results)
    write_csv(rows)

def write_csv(rows):
    print rows
    with open('share_activity_users.csv', 'w') as f:
        header = u'date,%s\n' % ','.join(rows['date'])
        f.write(header.encode('utf8'))
        del rows['date']

        for d, c in rows.items():
            f.write(u'%s,%s\n' % (d, ','.join([str(i) for i in c])))

def merge_data(data):
    print data
    results = {
        'date': [],
    }

    col = 0
    for k, val in data:
        results['date'].append(k)
        for date, count in val.items():
            if date not in results:
                if col == 0:
                    results[date] = [count]
                else:
                    l = [i * 0 for i in range(col)]
                    l.append(count)
                    results[date] = l
            else:
                # if len(results[date]) == col:
                results[date].append(count)
                # else:
                    # pass
        col += 1

    return results

def execute_sql(sql):
    cursor.execute(sql)
    rows = cursor.fetchall()
    d = {}
    for r in rows:
        d[r[0]] = r[1]
    return d


get_data()
