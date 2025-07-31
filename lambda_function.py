import boto3
import os

def lambda_handler(event, context):
    ec2 = boto3.client('ec2')

    instance1 = os.environ['INSTANCE1_ID']
    instance2 = os.environ['INSTANCE2_ID']

    response = ec2.describe_instance_status(
        InstanceIds=[instance1, instance2],
        IncludeAllInstances=True
    )

    states = {i['InstanceId']: i['InstanceState']['Name'] for i in response['InstanceStatuses']}
    state1 = states.get(instance1, 'stopped')
    state2 = states.get(instance2, 'stopped')

    print(f"Instance1: {state1}, Instance2: {state2}")

    if state1 == 'running' and state2 == 'running':
        ec2.stop_instances(InstanceIds=[instance2])
        print("Both running → Stopped Instance2")

    elif state1 == 'stopped' and state2 == 'stopped':
        ec2.start_instances(InstanceIds=[instance1])
        print("Both stopped → Started Instance1")

    elif state1 == 'running' and state2 == 'stopped':
        ec2.stop_instances(InstanceIds=[instance1])
        ec2.start_instances(InstanceIds=[instance2])
        print("Switched: Stopped Instance1 → Started Instance2")

    elif state1 == 'stopped' and state2 == 'running':
        ec2.stop_instances(InstanceIds=[instance2])
        ec2.start_instances(InstanceIds=[instance1])
        print("Switched: Stopped Instance2 → Started Instance1")
