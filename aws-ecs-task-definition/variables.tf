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
  type    = list(any)
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
  type    = list(any)
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


locals {
  entry_point = var.entry_point != "" ? ["sh", "-c", var.entry_point] : (var.entry_point_node_script != "" ? ["sh", "-c", "exec node --enable-source-maps ${var.entry_point_node_script}"] : [])
}
