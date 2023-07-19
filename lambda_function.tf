# Create a zip archive of the Lambda function code
data "archive_file" "zip" {
  type        = "zip"
  source_file = "lambda_function.py"
  output_path = "lambda_function.zip"
}

# Define an AWS Lambda function resource
resource "aws_lambda_function" "example" {
  function_name    = "cost-explorer-lambda"
  runtime          = "python3.9"
  handler          = "lambda_function.handler"
  timeout          = 60
  memory_size      = 128
  role             = aws_iam_role.lambda_role.arn  # IAM role ARN for the Lambda function's permissions
  filename         = data.archive_file.zip.output_path
}


# Create an SNS topic for alarm notifications
resource "aws_sns_topic" "alarm_topic" {
  name = "cost-exceeds-threshold-topic"
}

/*
# Subscribe the Lambda function to the SNS topic
resource "aws_sns_topic_subscription" "lambda_subscription" {
  topic_arn = aws_sns_topic.alarm_topic.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.lambda_read_send.arn
}
*/

# Create a CloudWatch metric alarm to trigger the SNS topic
/*
*/
resource "aws_cloudwatch_metric_alarm" "cost_percentage_alarm" {
  alarm_name          = "Cost Percentage Exceeds Threshold 8"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "CostPercentageMetric"
  namespace           = "CustomCostMetric"
  period              = 86400  # 1 day (in seconds)
  statistic           = "Average"
  threshold           = 8  # Adjust the threshold value as needed
  alarm_description   = "The cost percentage has exceeded the threshold"
  alarm_actions       = [aws_sns_topic.alarm_topic.arn]

}

resource "aws_cloudwatch_metric_alarm" "cost_percentage_alarm_2" {
  alarm_name          = "Cost Percentage Exceeds Threshold 50"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "CostPercentageMetric"
  namespace           = "CustomCostMetric"
  period              = 86400  # 1 day (in seconds)
  statistic           = "Average"
  threshold           = 50  # Adjust the threshold value as needed
  alarm_description   = "The cost percentage has exceeded the threshold"
  alarm_actions       = [aws_sns_topic.alarm_topic.arn]

}