This is Alert Feature for the XC3 project an open source project.

The Alerting Workflow introduces a dynamic and responsive system to optimize cost management within cloud environments. The feature is initiated by a CloudWatch event rule followed by the sequence of events. When Cloud watch even rule is triggered, it executes the Cost Metric Lambda function. This Lambda plays a pivotal role in collecting detailed cost data, presented in JSON format, from a specified S3 bucket. Following data collection, the Lambda employs a calculation to determine the cost percentage, which is then relayed to a dedicated CloudWatch Metric.

Continuous monitoring is enabled by CloudWatch, which observes the cost metric. In the event that the cost percentage exceeds a predefined threshold, CloudWatch promptly activates an alarm. After alarm is triggered, it published message to SNS topic. The SNS topic serves as an efficient intermediary, forwarding the JSON message to the Notifier Lambda.

The Notifier Lambda is a key component responsible for processing and transforming the JSON data into formatted notifications. These notifications are dispatched via two crucial communication channels: Email and Slack. Before dispatching emails, it is handled with help of SES. Then the end users will be able to view their cost notifications.

