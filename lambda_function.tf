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
