variable "ecs_cluster_name" {
  type    = string
  default = "fgr-ecs-cluster"
}

variable "ecs_service_name" {
  type = string
}

variable "cpu_target_value" {
  type        = number
  description = "The target average CPU utilization percentage for scaling."
  default     = 70
}

variable "min_capacity" {
  type = number
}

variable "max_capacity" {
  type = number
}


locals {
  resource_id = "service/${var.ecs_cluster_name}/${var.ecs_service_name}"
}
