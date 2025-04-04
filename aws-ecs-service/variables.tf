variable "capacity_provider_strategy" {
  type = map(map(number))
  default = {
    ondemand = {
      base   = 1
      weight = 1
    }
    spot = {
      base   = 0
      weight = 0
    }
  }
}

variable "dd_monitor_cpu_warning" {
  type    = number
  default = 80
}

variable "dd_monitor_cpu_critical" {
  type    = number
  default = 95
}

variable "dd_monitor_memory_warning" {
  type    = number
  default = 80
}

variable "dd_monitor_memory_critical" {
  type    = number
  default = 95
}

variable "desired_count" {
  type    = number
  default = 1
}

variable "env" {
  type = string
}

variable "health_check_grace_period_seconds" {
  type    = number
  default = 30
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

variable "register_service_connect" {
  type    = bool
  default = false
}

variable "service_name" {
  type = string
}

variable "service_port" {
  type    = number
  default = 4000
}

variable "task_definition_arn" {
  type = string
}

locals {
  lb_listener_rule_host_header = var.lb_listener_rule_host_header[var.env]
}
