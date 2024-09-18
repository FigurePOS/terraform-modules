variable "env" {
  type = string
}

variable "tags" {
  type    = list(string)
  default = []
}

variable "monitor_name" {
  type = string
}

variable "monitor_message" {
  type = string
}

variable "monitor_eval_interval" {
  type    = string
  default = "last_5m"
}

variable "monitor_eval_fn" {
  type    = string
  default = "max"
}

variable "monitor_query" {
  type = string
}

variable "warning_threshold" {
  type = number
}

variable "critical_threshold" {
  type = number
}

variable "slo_name" {
  type = string
}

variable "slo_thresholds" {
  type = list(object({ timeframe : string, target : number }))
}
