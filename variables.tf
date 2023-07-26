variable "namespace" {
  type        = string
  description = "The namespace referring to an env"
  default     = "example"
}

variable "maximum_budget" {
  description = "The maximum budget set by the user (in dollars)"
  type        = number
  default     = 1.0  # You can change the default value as needed
}

variable "threshold" {
  description = "The threshold for the cost percentage (in percent)"
  type        = number
  default     = 10  # Set as 10 for test purpose
}

variable "cloudwatch_namespace" {
  type        = string
  description = "Namespace for the CloudWatch metric"
  default     = "CustomCostMetric"
}

variable "metric_name" {
  type        = string
  description = "Name of the custom metric in CloudWatch"
  default     = "CostPercentageMetric"
}

variable "sender_email" {
  description = "Sender Email Address"
  type        = string
  default     = "104088013@student.swin.edu.au"
}

variable "recipient_email" {
  description = "Recipient Email Address"
  type        = string
  default     = "maharjanamir.101@gmail.com"
}

variable "region" {
  description = "Aws Region"
  type        = string
  default     = "ap-southeast-2"
}

variable "slack_channel_url" {
  description = "Slack Channel URL"
  type        = string
  default     = ""
}