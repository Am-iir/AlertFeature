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
resource "aws_cloudwatch_metric_alarm" "total_cost_percentage_alarm" {
  alarm_name          = "${var.namespace}- TotalCost PercentageAlarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = var.metric_name
  namespace           = var.cloudwatch_namespace
  period              = 86400  # 1 day (in seconds)
  statistic           = "Maximum"
  threshold           = var.threshold # Adjust the threshold value as needed
  alarm_description   = "The cost percentage has exceeded the threshold"
  alarm_actions       = [aws_sns_topic.alarm_topic.arn]

}

locals {
  resources_list = jsondecode(data.aws_s3_object.resources_data.body)
}

data "aws_s3_object" "resources_data" {
  bucket = var.bucket
  key    = "cost-metrics/resource_based_cost.json"
}

resource "aws_cloudwatch_metric_alarm" "resource_cost_percentage_alarm" {
  for_each = { for idx, item in local.resources_list : idx => item.Service }

  alarm_name          = "${each.value}-ResourceCost PercentageAlarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = each.value  # Use the Service attribute as the metric name
  namespace           = var.cloudwatch_namespace
  period              = 86400  # 1 day (in seconds)
  statistic           = "Maximum"
  threshold           =  var.threshold
  alarm_description   = "The cost percentage has exceeded the threshold"
  alarm_actions       = [aws_sns_topic.alarm_topic.arn]
}
