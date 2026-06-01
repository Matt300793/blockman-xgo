
# encoding: utf-8

import sys
import ConfigParser
import argparse
import boto3
import datetime

client = boto3.client('dynamodb', region_name="ap-northeast-2")

def backup_all_tables(retain_days):
    tables = list_all_talbes()
    for t in tables:
        backup_table(t, retain_days)

def backup_table(table_name, retain_days=None):
    backup_name = table_name + '-' + datetime.datetime.now().strftime("%Y%m%d%H%M%S")
    client.create_backup(
        TableName=table_name,
        BackupName=backup_name
    )

    if retain_days and retain_days > 0:
        now = datetime.datetime.now()
        days = datetime.timedelta(days=retain_days)
        days_before = now - days
        backups = client.list_backups(
            TableName=table_name,
            Limit=100,
            TimeRangeUpperBound=days_before,
            BackupType='USER'
        )

        for b in backups.get('BackupSummaries', []):
            client.delete_backup(BackupArn=b.get('BackupArn', ''))

def list_all_talbes():
    tables = []
    res = client.list_tables(Limit=100)
    for t in res.get('TableNames'):
        tables.append(t)
    
    while res.get('LastEvaluatedTableName'):
        res = client.list_tables(Limit=100, ExclusiveStartTableName=res.get('LastEvaluatedTableName'))
        for t in res.get('TableNames'):
            tables.append(t)

    return tables

def calculate_table_size(tables):
    total_item = 0
    total_size = 0
    for t in tables:
        res = client.describe_table(TableName=t)
        total_item += res.get("Table").get("ItemCount")
        total_size += res.get("Table").get("TableSizeBytes")
    return total_item, total_size

def parse_args():
    description = u'Game dynamodb table backup'
    parser = argparse.ArgumentParser(description=description)

    parser.add_argument('-l', '--list', action="store_true", help=u'list all tables')
    parser.add_argument('-b', '--backup', action="store_true", help=u'backup tables')
    parser.add_argument('-t', '--table', help=u'table name')
    parser.add_argument('-c', '--count-size', action="store_true", help=u'count all tables total size')
    parser.add_argument('--retain-days', type=int, help=u'remove backups created before retain days')

    return parser.parse_args()

def main():
    if len(sys.argv) == 1:
        sys.argv.append('--help')

    args = parse_args()

    if args.list:
        talbes = list_all_talbes()
        for t in talbes:
            print(t)
    elif args.backup:
        if args.table:
            backup_table(args.table, args.retain_days)
        else:
            backup_all_tables(args.retain_days)
    elif args.count_size:
        tables = list_all_talbes()
        item_count, total_size = calculate_table_size(tables)
        print("total item count: %d" % item_count)
        print("total table size bytes: %d" % total_size)

if __name__ == "__main__":
    main()
