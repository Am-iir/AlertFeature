# Define an IAM role for the Lambda function
resource "aws_iam_role" "lambda_role" {
  name = "${var.namespace}-cost-metric-lambda-role"

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

# Attach the AWS Lambda basic execution role policy to the IAM role
resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Define a custom IAM policy for Cost Explorer and CloudWatch access
resource "aws_iam_policy" "custom_policy" {
  name        = "${var.namespace}-CustomCostExplorerCloudWatchPolicy"  # Name of the custom policy
  description = "Custom policy for Cost Explorer and CloudWatch access"

  # Define the policy document allowing ce:GetCostAndUsage, cloudwatch:PutMetricAlarm, and cloudwatch:PutMetricData actions
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ce:GetCostAndUsage",
        "cloudwatch:PutMetricAlarm",
        "cloudwatch:PutMetricData"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

# Attach the custom policy to the IAM role
resource "aws_iam_role_policy_attachment" "cost_explorer_cloudwatch_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.custom_policy.arn
}
