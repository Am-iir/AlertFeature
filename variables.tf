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