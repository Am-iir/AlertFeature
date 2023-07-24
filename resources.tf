# Create an SNS topic for alarm notifications
resource "aws_sns_topic" "alarm_topic" {
  name = "${var.namespace}-cost-exceeds-threshold-topic"
}

# Subscribe the Lambda function to the SNS topic
resource "aws_sns_topic_subscription" "lambda_subscription" {
  topic_arn = aws_sns_topic.alarm_topic.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.notifier.arn
}

# Create a CloudWatch metric alarm to trigger the SNS topic
/*
*/
resource "aws_cloudwatch_metric_alarm" "cost_percentage_alarm" {
  alarm_name          = "${var.namespace}-Cost Percentage Exceeds Threshold 8"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = var.metric_name
  namespace           = var.cloudwatch_namespace
  period              = 86400  # 1 day (in seconds)
  statistic           = "Average"
  threshold           = var.threshold # Adjust the threshold value as needed
  alarm_description   = "The cost percentage has exceeded the threshold"
  alarm_actions       = [aws_sns_topic.alarm_topic.arn]

}