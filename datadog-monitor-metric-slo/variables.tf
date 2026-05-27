variable "critical_threshold" {
  type = number
}

variable "env" {
  type = string
}

variable "monitor_eval_fn" {
  type    = string
  default = "max"
}

variable "monitor_eval_interval" {
  type    = string
  default = "last_5m"
}

variable "monitor_message" {
  type = string
}

variable "monitor_name" {
  type = string
}

variable "monitor_query" {
  type = string
}

variable "service_name" {
  type = string
}

variable "slo_name" {
  type = string
}

variable "slo_thresholds" {
  type = list(object({ timeframe : string, target : number }))
}

variable "tags" {
  type    = list(string)
  default = []
}

variable "warning_threshold" {
  type = number
}
