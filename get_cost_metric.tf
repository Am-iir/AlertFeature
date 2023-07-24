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
      MAXIMUM_BUDGET = var.maximum_budget
      CLOUDWATCH_NAMESPACE = var.cloudwatch_namespace
      METRIC_NAME = var.metric_name
    }
  }
}






