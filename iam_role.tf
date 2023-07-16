# Define an IAM role for the Lambda function
resource "aws_iam_role" "lambda_role" {
  name = "cost-explorer-lambda-role"

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

# Define a custom IAM policy for Cost Explorer access
resource "aws_iam_policy" "custom_policy" {
  name        = "CustomCostExplorerPolicy"  # Name of the custom policy
  description = "Custom policy for Cost Explorer access"

  # Define the policy document allowing ce:GetCostAndUsage action on all resources
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "ce:GetCostAndUsage",
      "Resource": "*"
    }
  ]
}
EOF
}

# Attach the custom policy to the IAM role
resource "aws_iam_role_policy_attachment" "cost_explorer_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.custom_policy.arn
}
