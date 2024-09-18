
variable "env" {
  type = string
}

variable "resource_name" {
  type = string
}

variable "resource_name_readable" {
  type = string
}
variable "service_name" {
  type = string
}

variable "interval" {
  type = string
  default = "last_10m"
}

variable "eval_fn" {
  type = string
  default = "min"
}

variable "error_rate_target" {
  type = number
}

variable "latency_percentile" {
  type = string
  default = "p99"
}

variable "latency_target" {
  type = number
}

variable "tags" {
  type = list(string)
  default = []
}

variable "message" {
  type = string
  default = "{{#is_alert}}@slack-platform-warnings{{/is_alert}} {{#is_alert_recovery}}@slack-platform-warnings{{/is_alert_recovery}}"
}

variable "notify_on_missing_data" {
  type = bool
  default = false
}
