data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "message_function.py"
  output_path = "message_function.zip"
}

resource "aws_lambda_function" "lambda_read_send" {
  function_name    = "lambda_read_send"
  runtime          = "python3.9"
  handler          = "message_function.lambda_handler"
  timeout          = 60
  memory_size      = 128
  role             = aws_iam_role.lambda_read_send_role.arn
  filename         = data.archive_file.lambda_zip.output_path
}

# Create an IAM role for the Lambda function
resource "aws_iam_role" "lambda_read_send_role" {
  name = "lambda_read_send"

  # Define the trust policy to allow the Lambda service to assume this role
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

# Attach the necessary policies to the IAM role
resource "aws_iam_role_policy_attachment" "lambda_basic_execution_attachment" {
  role       = aws_iam_role.lambda_read_send_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Define a custom IAM policy for Send Email permissions
resource "aws_iam_policy" "lambda_read_send_custom_policy" {
  name        = "CombinedLambdaCustomPolicy"
  description = "Custom IAM policy for combined Lambda function"

  # Define the policy document allowing the "ses:SendEmail" action
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ses:SendEmail"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

# Attach the custom policy to the IAM role
resource "aws_iam_role_policy_attachment" "lambda_read_send_custom_policy_attachment" {
  role       = aws_iam_role.lambda_read_send_role.name
  policy_arn = aws_iam_policy.lambda_read_send_custom_policy.arn
}

# Attach the Amazon SES policy to the IAM role
resource "aws_iam_role_policy_attachment" "lambda_ses_policy_attachment" {
  role       = aws_iam_role.lambda_read_send_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSESFullAccess"
}
