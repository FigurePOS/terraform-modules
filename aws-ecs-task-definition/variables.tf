variable "aws_account_id" {
  type = string
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "dd_agent_version" {
  type    = string
  default = "latest"
}

variable "deployment_tag" {
  type = string
}

variable "ecr_repository_uri" {
  type = string
}

variable "entry_point" {
  type    = string
  default = ""
}

variable "entry_point_node_script" {
  type    = string
  default = ""
}

variable "env" {
  type = string
}

variable "git_commit_hash" {
  type = string
}

variable "git_repository" {
  type = string
}

variable "readonly_root_filesystem" {
  type    = bool
  default = true
}

variable "service_envs" {
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "service_name" {
  type = string
}

variable "service_port" {
  type    = number
  default = 4000
}

variable "service_secrets" {
  type = list(object({
    name      = string
    valueFrom = string
  }))
  default = []
}

variable "task_cpu" {
  type    = number
  default = 256
}

variable "task_memory" {
  type    = number
  default = 512
}

variable "task_execution_policy" {
  type    = any
  default = null
}

variable "task_policy" {
  type    = any
  default = null
}

variable "ulimits" {
  type    = list(any)
  default = []
}

variable "otel_traces_sampler" {
  type        = string
  default     = "parentbased_traceidratio"
  description = "The OpenTelemetry traces sampler to use. Defaults to 'parentbased_traceidratio'. Only used if otel_traces_sampler_arg is set."
}

variable "otel_traces_sampler_arg" {
  type        = string
  default     = ""
  description = "If non-empty, adds OTEL_TRACES_SAMPLER (using otel_traces_sampler variable) and OTEL_TRACES_SAMPLER_ARG (this value) to the app container environment."
}


locals {
  entry_point = var.entry_point != "" ? ["sh", "-c", var.entry_point] : (var.entry_point_node_script != "" ? ["sh", "-c", "exec node --enable-source-maps --no-network-family-autoselection --dns-result-order=ipv4first ${var.entry_point_node_script}"] : [])
}
