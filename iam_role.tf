# Define an IAM role for the Lambda function
resource "aws_iam_role" "lambda_role" {
  name = "${var.namespace}-cost-metric-lambda-role"

  # Define the trust policy to allow the Lambda service to assume this role
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      },
    ]
  })
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
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ce:GetCostAndUsage",
          "cloudwatch:PutMetricAlarm",
          "cloudwatch:PutMetricData"
        ]
        Resource = "*"
      }
    ]
  })
}

# Attach the custom policy to the IAM role
resource "aws_iam_role_policy_attachment" "cost_explorer_cloudwatch_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.custom_policy.arn
}

# Define a custom IAM policy for S3 bucket access
resource "aws_iam_policy" "s3_bucket_access_policy" {
  name        = "${var.namespace}-S3BucketAccessPolicy"
  description = "Custom IAM policy for S3 bucket access"

  # Define the policy document allowing read access to the specific S3 bucket
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket",
        ]
        Resource = [
          "arn:aws:s3:::alocal2-metadata-storage",
          "arn:aws:s3:::alocal2-metadata-storage/*",
        ]
      },
    ]
  })
}

# Attach the S3 bucket access policy to the IAM role
resource "aws_iam_role_policy_attachment" "s3_bucket_access_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.s3_bucket_access_policy.arn
}

resource "aws_iam_policy" "sns_publish_policy" {
  name = "SNSPublishPolicy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow",
        Action   = "sns:Publish",
        Resource = aws_sns_topic.alarm_topic.arn,
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "sns_publish_policy_attachment" {
  policy_arn = aws_iam_policy.sns_publish_policy.arn
  role       = aws_iam_role.lambda_role.name
}
