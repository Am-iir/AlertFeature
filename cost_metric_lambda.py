import boto3
import json
import os
from datetime import datetime
from botocore.exceptions import ClientError


def handler(event, context):
    try:

        handle_total_account()

        handle_resource_cost()

        # Publish the alarm to the SNS topic along with the calculated values
        # publish_to_sns(cost_percentage, maximum_budget, total_cost)

        return {
            'statusCode': 200,
            'body': json.dumps('Cost data retrieved from S3 and pushed to CloudWatch Metrics')
        }
    except ClientError as e:
        if e.response['Error']['Code'] == 'NoSuchKey':
            # JSON file is not found, provide an error message
            return {
                'statusCode': 400,
                'body': json.dumps(
                    'Total account cost JSON file not found. Please run the total account cost Lambda function first.')
            }
        else:
            return {
                'statusCode': 500,
                'body': json.dumps(
                    'Something Went Wrong.')
            }


def calculate_cost_percentage(cost, maximum_budget):
    if maximum_budget > 0:
        return (cost / maximum_budget) * 100
    else:
        return 0.0


def get_json_data(file_name):
    bucket_name = os.environ['BUCKET']
    directory_name = 'cost-metrics'

    json_file = f'{directory_name}/{file_name}'

    s3_client = boto3.client('s3')
    response = s3_client.get_object(Bucket=bucket_name, Key=json_file)
    json_data = response['Body'].read().decode('utf-8')
    # Parse the JSON data to extract the cost information
    return json.loads(json_data)


def handle_total_account():
    total_cost_file_name = 'total_account_cost.json'

    total_account_cost_data = get_json_data(total_cost_file_name)

    # Get the current month in the format "January", "February", etc.
    current_month = datetime.utcnow().strftime('%B')

    # Get the account ID from the cost_data dictionary
    account_id = list(total_account_cost_data.keys())[0]

    # Get the total cost for the current month
    total_cost = total_account_cost_data[account_id].get(current_month, 0.0)

    maximum_budget = float(os.environ['MAXIMUM_BUDGET'])

    cost_percentage = calculate_cost_percentage(total_cost, maximum_budget)

    # Publish the cost percentage as a custom metric to CloudWatch Metrics

    publish_to_cloudwatch(os.environ['METRIC_NAME'], cost_percentage)
    publish_to_sns(cost_percentage, maximum_budget, total_cost)


def handle_resource_cost():
    file_name = 'resource_based_cost.json'
    maximum_budget = float(os.environ['MAXIMUM_BUDGET'])

    resources_data = get_json_data(file_name)

    for resource in resources_data:
        service = resource.get('Service')
        cost = float(resource.get('Cost', 0.0))

        # Calculate the cost percentage based on the maximum budget
        cost_percentage = calculate_cost_percentage(cost, maximum_budget)

        # Process the data as needed (e.g., push to CloudWatch, generate alarms, etc.)
        if cost_percentage > 0:
            publish_to_cloudwatch(service, cost_percentage)
            # Generate alarms here if required based on cost_percentage and the threshold


def publish_to_cloudwatch(metric_name, cost_percentage):
    cloudwatch = boto3.client('cloudwatch')

    # Get the namespace from environment variables
    cloudwatch_namespace = os.environ['CLOUDWATCH_NAMESPACE']

    # Publish the cost percentage as a custom metric
    cloudwatch.put_metric_data(
        Namespace=cloudwatch_namespace,
        MetricData=[
            {
                'MetricName': metric_name,
                'Value': cost_percentage,
                'Unit': 'Percent'
            }
        ]
    )


def publish_to_sns(cost_percentage, maximum_budget, total_cost):
    sns_client = boto3.client('sns')

    # Get the ARN of the SNS topic to which the notifier_lambda is subscribed
    sns_topic_arn = os.environ['SNS_TOPIC_ARN']

    # Create the message to be sent in the SNS notification
    message = {
        'cost_percentage': cost_percentage,
        'maximum_budget': maximum_budget,
        'total_cost': total_cost
    }

    try:
        # Publish the message to the SNS topic
        sns_client.publish(
            TopicArn=sns_topic_arn,
            Message=json.dumps(message)
        )
    except ClientError as e:
        # Handle the SNS publish error here
        print(f"Failed to publish message to SNS topic: {e}")
        # You can choose to log the error or take any other necessary actions
