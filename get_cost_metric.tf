# Create a zip archive of the Lambda function code
data "archive_file" "zip" {
  type        = "zip"
  source_file = "cost_metric_lambda.py"
  output_path = "cost_metric_lambda.zip"
}

# Define an AWS Lambda function resource
resource "aws_lambda_function" "cost_metric_lambda" {
  function_name    = "${var.namespace}-cost_metric_lambda"
  runtime          = "python3.9"
  handler          = "cost_metric_lambda.handler"
  timeout          = 60
  memory_size      = 128
  role             = aws_iam_role.lambda_role.arn  # IAM role ARN for the Lambda function's permissions
  filename         = data.archive_file.zip.output_path

  # Set the environment variable for the Lambda function
  environment {
    variables = {
      BUCKET = var.bucket
      MAXIMUM_BUDGET = var.maximum_budget
      CLOUDWATCH_NAMESPACE = var.cloudwatch_namespace
      METRIC_NAME = var.metric_name
      SNS_TOPIC_ARN = aws_sns_topic.alarm_topic.arn
    }
  }
}

resource "aws_cloudwatch_event_rule" "lambda_schedule" {
  name                = "LambdaScheduleRule"
  description         = "Schedule Lambda to run every day"
  schedule_expression = "cron(0 0 * * ? *)"  # Run at 00:00 UTC every day
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.lambda_schedule.name
  arn       = aws_lambda_function.cost_metric_lambda.arn
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.cost_metric_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.lambda_schedule.arn
}





