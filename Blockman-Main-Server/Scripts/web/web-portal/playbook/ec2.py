#!/usr/bin/env python
# encoding: utf-8

import boto3
import base64
import os
import logging
DEFAULT_REGION = 'us-east-1'


class Ec2:
    ec2 = None
    region = None

    def __init__(self, region=DEFAULT_REGION):
        self.region = region
        self.ec2 = boto3.client('ec2',
                                region)

    def launch(self, count, ima_id='', instance_type='', sgs=[],  subnet='', vpc='', tags=[], user_data='', instance_profile={}):
        self.vpcId = vpc
        self.subnet = subnet
        instance_tags = []
        for k, v in tags.items():
            instance_tags.append({'Key': k, 'Value': v})
        result = self.ec2.run_instances(
            ImageId=ima_id,
            MinCount=count,
            MaxCount=count,
            KeyName='admin',
            InstanceType=instance_type,
            SecurityGroupIds=sgs,
            # SecurityGroups=sgs, # [EC2-Classic, default VPC] One or more security group names. For a nondefault VPC, you must use security group IDs instead.
            Monitoring={
                'Enabled': True
            },
            DisableApiTermination=False,
            InstanceInitiatedShutdownBehavior='stop',
            EbsOptimized=False,
            SubnetId=self.subnet,
            TagSpecifications=[{
                'ResourceType': 'instance',
                'Tags': instance_tags
            }],
            BlockDeviceMappings=[{
                'DeviceName': '/dev/sda1',
                'Ebs': {
                    'DeleteOnTermination': True,
                    'VolumeType': 'gp2'
                }
            }],
            UserData=user_data,
            IamInstanceProfile=instance_profile
        )

        ids = [ins['InstanceId'] for ins in result['Instances']]
        self.wait_instances_running(ids, "instance_status_ok")
        return result

    def terminate(self, ids):
        return self.ec2.terminate_instances(InstanceIds=ids)

    def find_security_groups_via_subnet(self, subnet):
        response = self.ec2.describe_subnets(SubnetIds=[subnet])
        try:
            vpc = response['Subnets'][0]['VpcId']
            result = self.describe_security_groups_by_vpc(vpc)
            return result
        except:
            return None

    def describe_security_groups_by_vpc(self, vpc):
        filters = [{'Name': 'vpc-id', 'Values': [vpc]}]
        result = self.ec2.describe_security_groups(Filters=filters)

        try:
            result = [{gn['GroupName']:gn['GroupId']} for gn in result['SecurityGroups']]
            return result
        except:
            return None

    def stop(self, ids):
        return self.ec2.stop_instances(InstanceIds=ids)

    def start(self, ids):
        return self.ec2.start_instances(InstanceIds=ids)

    def wait_instances_running(self, ids, waiter="instance_running"):
        waiter = self.ec2.get_waiter(waiter)
        waiter.wait(InstanceIds=ids)

    def describe_instances(self, instance_ids=[], filters=[]):
        return self.ec2.describe_instances(InstanceIds=instance_ids, Filters=filters)

    def create_tags(self, resource_ids, tags):
        self.ec2.create_tags(
            Resources=resource_ids,
            Tags=tags
        )

    def delete_tags(self, resource_ids, tags):
        self.ec2.delete_tags(Resources=resource_ids, Tags=tags)

    def create_security_group(self, name):
        self.ec2.create_security_group(
            DryRun=True,
            GroupName=name,
            Description='sg for %s' % name,
            #            VpcId='vpc-1d079e79'
            VpcId=self.vpcId
        )

    def get_instances_by_name(self, name):
        return self.ec2.describe_instances(Filters=[
            {
                'Name': 'tag:Name',
                "Values": [name]
            }
        ])

    def get_instances_by_tag_key(self, key, other_filters=[]):
        filters = [
            {
                'Name': 'tag-key',
                'Values': [key]
            }
        ]
        if other_filters:
            filters.extend(other_filters)
        return self.ec2.describe_instances(Filters=filters)

    def get_instances_by_tags(self, tags, other_filters=[]):
        filters = []
        for k, v in tags.items():
            filters.append({
                'Name': 'tag:%s' % k,
                'Values': [v]
            })
        if len(other_filters) > 0:
            filters.extend(other_filters)

        return self.ec2.describe_instances(Filters=filters, MaxResults=1000)

    def get_instances_by_private_ips(self, ips):
        return self.ec2.describe_instances(Filters=[
            {
                'Name': 'private-ip-address',
                'Values': ips
            }
        ])

    def describe_subnets(self, vpc_id):
        return self.ec2.describe_subnets(Filters=[
            {
                'Name': 'vpc-id',
                'Values': [vpc_id]
            }
        ])


class LoadBlancing:
    def __init__(self, region=DEFAULT_REGION, byvpc=None, bysubnet=None):

        self.client = boto3.client('elbv2', region)

    def register_target(self, arn, id):
        return self.client.register_targets(
            TargetGroupArn=arn,
            Targets=[
                {
                    'Id': id
                },
            ]
        )

    def diregister_target(self, arn, id):
        return self.client.deregister_targets(
            TargetGroupArn=arn,
            Targets=[
                {
                    'Id': id
                },
            ]
        )

    def describe_target_health(self, arn, id=None):
        targets = []
        if id:
            targets = [{'Id': id}]

        return self.client.describe_target_health(
            TargetGroupArn=arn,
            Targets=targets
        )
