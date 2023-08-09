import boto3
import json
import os

def lambda_handler(event, context):
    # Extract the SNS message from the Lambda event
    sns_message = json.loads(event['Records'][0]['Sns']['Message'])

    # Extract relevant details from the SNS message
    alarm_name = sns_message['AlarmName']
    alarm_description = sns_message['AlarmDescription']
    aws_account_id = sns_message['AWSAccountId']
    threshold = sns_message['Trigger']['Threshold']

    # Compose the email subject and body
    subject = f"CloudWatch Alarm Triggered: {alarm_name}"
    body = (
        f"Alarm Name: {alarm_name}\n"
        f"Alarm Description: {alarm_description}\n"
        f"AWS Account ID: {aws_account_id}\n"
        f"Threshold from Trigger: {threshold}\n"
    )

    # Send the email
    send_email(subject, body)

    return "Email sent successfully"

def send_email(subject, body):
    # Configure the email sender
    sender_email = "santoshs.pokhrel@gmail.com"
    recipient_email = "maharjanamir.101@gmail.com"
    aws_region = os.environ["region"]

    # Create an AWS Simple Email Service (SES) client
    ses = boto3.client('ses', region_name=aws_region)

    # Send the email
    response = ses.send_email(
        Source=sender_email,
        Destination={'ToAddresses': [recipient_email]},
        Message={
            'Subject': {'Data': subject},
            'Body': {'Text': {'Data': body}}
        }
    )

    return response
