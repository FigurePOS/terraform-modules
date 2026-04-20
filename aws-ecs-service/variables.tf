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

variable "cpu_utilization_alarm_warning_threshold" {
  type        = number
  description = "Average service CPU utilization (0–100) above which the CloudWatch warning alarm triggers."
  default     = 80
}

variable "cpu_utilization_alarm_critical_threshold" {
  type        = number
  description = "Average service CPU utilization (0–100) above which the CloudWatch critical alarm triggers."
  default     = 95

  validation {
    condition     = var.cpu_utilization_alarm_warning_threshold < var.cpu_utilization_alarm_critical_threshold
    error_message = "cpu_utilization_alarm_warning_threshold must be strictly less than cpu_utilization_alarm_critical_threshold."
  }
}

variable "memory_utilization_alarm_warning_threshold" {
  type        = number
  description = "Average service memory utilization (0–100) above which the CloudWatch warning alarm triggers."
  default     = 80
}

variable "memory_utilization_alarm_critical_threshold" {
  type        = number
  description = "Average service memory utilization (0–100) above which the CloudWatch critical alarm triggers."
  default     = 95

  validation {
    condition     = var.memory_utilization_alarm_warning_threshold < var.memory_utilization_alarm_critical_threshold
    error_message = "memory_utilization_alarm_warning_threshold must be strictly less than memory_utilization_alarm_critical_threshold."
  }
}

variable "cloudwatch_evaluation_periods" {
  type        = number
  description = "The number of periods over which the ECS utilization metric is compared to the threshold."
  default     = 1
}

variable "cloudwatch_period_seconds" {
  type        = number
  description = "Metric period in seconds for ECS utilization alarms (e.g. 300 for a five-minute window)."
  default     = 300
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
