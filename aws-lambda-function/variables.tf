variable "datadog_extension_layer_version" {
  description = "Datadog extension layer version (receives OTLP and forwards to Datadog)"
  type        = number
  default     = 90
}

variable "description" {
  description = "Description of the Lambda function"
  type        = string
  default     = ""
}

variable "env" {
  description = "Environment (dev, qa, staging, etc.)"
  type        = string
}

variable "environment_variables" {
  description = "Environment variables for the Lambda function"
  type        = map(string)
  default     = {}
}

variable "function_name" {
  description = "Name of the Lambda function"
  type        = string
}

variable "git_commit_hash" {
  description = "Git commit hash for tagging"
  type        = string
  default     = ""
}

variable "git_repository_url" {
  description = "Git repository URL for tagging"
  type        = string
  default     = ""
}

variable "handler" {
  description = "Lambda function handler (e.g. 'index.handler')"
  type        = string
}

variable "layers" {
  description = "List of Lambda Layer ARNs to attach"
  type        = list(string)
  default     = []
}

variable "memory_size" {
  description = "Lambda function memory size in MB"
  type        = number
  default     = 128
}

variable "no_bundle" {
  description = "Whether to pass --no-bundle flag to fgr lambda build command"
  type        = bool
  default     = false
}

variable "policy_documents" {
  description = "List of IAM policy documents for the Lambda function"
  type        = list(any)
  default     = []
}

variable "reserved_concurrent_executions" {
  description = "Amount of reserved concurrent executions for this Lambda function. A value of 0 disables Lambda from being triggered and -1 removes any concurrency limitations. Defaults to -1 if not specified."
  type        = number
  default     = -1
}

variable "role_name" {
  description = "Name of the IAM role for the Lambda function"
  type        = string
}

variable "runtime" {
  description = "Lambda function runtime"
  type        = string
  default     = "nodejs24.x"
}

variable "schedule_description" {
  description = "Description for the CloudWatch Event Rule"
  type        = string
  default     = ""
}

variable "schedule_expression" {
  description = "CloudWatch Events schedule expression (cron or rate) for Lambda function. Empty means no scheduling."
  type        = string
  default     = ""
}

variable "service_name" {
  description = "Service name for tagging and identification"
  type        = string
}

variable "source_dir" {
  description = "Directory containing Lambda function source code (absolute path or relative to the Terraform root)"
  type        = string
}

variable "tags" {
  description = "Tags to attach to resources"
  type        = map(string)
  default     = {}
}

variable "timeout" {
  description = "Lambda function timeout in seconds"
  type        = number
  default     = 30
}

variable "vpc_security_group_ids" {
  description = "List of security group IDs for Lambda VPC configuration"
  type        = list(string)
  default     = []
}

variable "vpc_subnet_ids" {
  description = "List of subnet IDs for Lambda VPC configuration"
  type        = list(string)
  default     = []
}

# CloudWatch Alarms Configuration
variable "enable_cloudwatch_alarms" {
  description = "Whether to enable CloudWatch alarms for the Lambda function"
  type        = bool
  default     = true
}

variable "cloudwatch_evaluation_periods" {
  description = "The number of evaluation periods for CloudWatch alarms"
  type        = number
  default     = 1
}

variable "cloudwatch_period_seconds" {
  description = "The period in seconds for CloudWatch metric evaluation"
  type        = number
  default     = 60
}

variable "lambda_errors_threshold" {
  description = "The number of errors to trigger an alarm"
  type        = number
  default     = 5
}

variable "lambda_throttles_threshold" {
  description = "The number of throttles to trigger an alarm"
  type        = number
  default     = 1
}

variable "lambda_duration_threshold_percentage" {
  description = "The percentage of timeout duration to trigger an alarm (e.g., 80 for 80% of timeout)"
  type        = number
  default     = 80
  validation {
    condition     = var.lambda_duration_threshold_percentage > 0 && var.lambda_duration_threshold_percentage <= 100
    error_message = "The lambda_duration_threshold_percentage must be between 1 and 100."
  }
}

variable "lambda_concurrent_executions_threshold" {
  description = "The number of concurrent executions to trigger an alarm"
  type        = number
  default     = 50
}

variable "lambda_error_rate_threshold" {
  description = "The error rate percentage to trigger an alarm (e.g., 5 for 5%)"
  type        = number
  default     = 5
  validation {
    condition     = var.lambda_error_rate_threshold >= 0 && var.lambda_error_rate_threshold <= 100
    error_message = "The lambda_error_rate_threshold must be between 0 and 100."
  }
}
