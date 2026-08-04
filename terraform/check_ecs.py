import boto3
try:
    ecs = boto3.client('ecs', region_name='us-east-1')
    response = ecs.list_tasks(cluster='llm-app-cluster', serviceName='grafana-service', desiredStatus='STOPPED')
    tasks = response.get('taskArns', [])
    if tasks:
        task_details = ecs.describe_tasks(cluster='llm-app-cluster', tasks=tasks[:3])
        for t in task_details['tasks']:
            print(f"Task: {t['taskArn']}")
            print(f"StopCode: {t.get('stopCode')}")
            print(f"StoppedReason: {t.get('stoppedReason')}")
            for c in t.get('containers', []):
                print(f"  Container: {c['name']} - Reason: {c.get('reason')} - ExitCode: {c.get('exitCode')}")
    else:
        print('No stopped tasks found.')
except Exception as e:
    print(f"Error: {e}")
