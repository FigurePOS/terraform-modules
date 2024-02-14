variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "deployment_tag" {
  type = string
}

variable "desired_count" {
  type    = number
  default = 1
}

variable "ecr_repository_url" {
  type = string
}

variable "ecs_cluster_name" {
  type = string
  default = "fgr-ecs-cluster"
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

variable "lb_health_check_healthy_threshold" {
  type    = number
  default = 3
}

variable "lb_health_check_path" {
  type = string
}

variable "lb_health_check_unhealthy_threshold" {
  type    = number
  default = 2
}

variable "lb_listener_rule_host_header" {
  type = map(list(string))
  default = {
    development = ["api2-dev.figurepos.com", "dev.figureapi.dev"]
    production  = ["api2.figurepos.com", "prod.figureapi.dev"]
  }
}

variable "lb_listener_rule_path_pattern" {
  type = list(string)
}

variable "lb_name" {
  type = string
  default = "fgr-ecs-load-balancer"
}

variable "service_custom_definition" {
  type    = map(any)
  default = {}
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

variable "task_execution_role_arn" {
  type = string
}
variable "task_role_arn" {
  type = string
}


locals {
  lb_listener_rule_host_header = var.lb_listener_rule_host_header[var.env]
  entry_point                  = var.entry_point != "" ? ["sh", "-c", var.entry_point] : (var.entry_point_node_script != "" ? ["sh", "-c", "exec node --enable-source-maps ${var.entry_point_node_script}"] : [])
}
