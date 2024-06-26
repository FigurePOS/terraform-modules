variable "ecs_cluster_name" {
  type    = string
  default = "fgr-ecs-cluster"
}

variable "ecs_service_name" {
  type = string
}

variable "low_cpu_threshold" {
  type    = number
  default = 50
}

variable "high_cpu_threshold" {
  type    = number
  default = 75
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
