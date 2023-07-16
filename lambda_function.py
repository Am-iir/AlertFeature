import boto3
import json
from prometheus_client import CollectorRegistry, Gauge, push_to_gateway

def handler(event, context):
    # Create a Cost Explorer client in the EU (Ireland) region
    cost_explorer = boto3.client('ce', region_name='eu-west-1')

    # Retrieve the cost data using the appropriate Cost Explorer API method
    response = cost_explorer.get_cost_and_usage(
        TimePeriod={
            'Start': '2023-07-01',
            'End': '2023-07-31'
        },
        Granularity='DAILY',
        Metrics=[
            'BlendedCost',
        ]
    )

    # Transform the cost data as needed
    transformed_data = transform_data(response)

    # Push the transformed data to the Push Gateway using HTTP or a suitable client library
    push_to_gateway(transformed_data)

    return {
        'statusCode': 200,
        'body': json.dumps('Cost data retrieved and pushed to Push Gateway')
    }

def transform_data(data):

    transformed_data = []
    for result in data['ResultsByTime']:
        transformed_data.append({
            'time': result['TimePeriod']['Start'],
            'cost': result['Total']['BlendedCost']['Amount']
        })
    return transformed_data

def push_to_gateway(data):
    job_name = 'pushJob'  # Specify the job name for the metrics

    # Create a list to store the metrics
    metrics = []

    # Iterate over the transformed data and create Prometheus metrics
    for item in data:
        time = item['time']
        cost = item['cost']

        # Create a Gauge metric for the cost data
        metric = Gauge('blended_cost', 'Blended cost', ['time'])
        metric.labels(time).set(cost)

        # Add the metric to the list
        metrics.append(metric)

    # Push the metrics to the Push Gateway
    push_to_gateway('localhost:9091', job=job_name, registry=metrics)

    print("Pushing data to Push Gateway")
    print(data)