import boto3
import json
from botocore.exceptions import ClientError

def lambda_handler(event, context):

    send_email()

    return {
        'statusCode': 200,
        'body': json.dumps('Cost data retrieved and email sent')
    }

def send_email():
    SENDER = "104088013@student.swin.edu.au"
    RECIPIENT = "maharjanamir.101@gmail.com"
    AWS_REGION = "eu-west-1"
    SUBJECT = "Cost Metrics Report"
    BODY_TEXT = "alarm Triggered"
    BODY_HTML = f"<html><body><h1>Cost Metrics Report</h1><pre>Cost Data Treshhold Alarm</pre></body></html>"
    CHARSET = "UTF-8"

    client = boto3.client('ses', region_name=AWS_REGION)

    try:
        response = client.send_email(
            Destination={
                'ToAddresses': [RECIPIENT],
            },
            Message={
                'Body': {
                    'Html': {
                        'Charset': CHARSET,
                        'Data': BODY_HTML,
                    },
                    'Text': {
                        'Charset': CHARSET,
                        'Data': BODY_TEXT,
                    },
                },
                'Subject': {
                    'Charset': CHARSET,
                    'Data': SUBJECT,
                },
            },
            Source=SENDER,
        )
        print("Email sent! Message ID:", response['MessageId'])
    except ClientError as e:
        print(e.response['Error']['Message'])
