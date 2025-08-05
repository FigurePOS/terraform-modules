variable "datadog_extension_layer_version" {
  description = "Datadog extension layer version"
  type        = number
  default     = 83
}

variable "datadog_layer_version" {
  description = "Datadog layer version"
  type        = number
  default     = 127
}

variable "dd_service_mapping" {
  description = "Datadog service mapping for DD_SERVICE_MAPPING environment variable."
  type        = string
  default     = ""
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

variable "output_dir" {
  description = "Directory where build artifacts will be stored (defaults to .build in Terraform root)"
  type        = string
  default     = ".build"
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
  default     = "nodejs22.x"
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
