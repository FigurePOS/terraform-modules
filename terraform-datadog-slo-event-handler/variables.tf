
variable "env" {
  type = string
}

variable "service" {
  type = string
}

variable "resource_name" {
  type = string
}

variable "service_name_readable" {
  type = string
}

variable "resource_name_readable" {
  type = string
}

variable "interval" {
  type = string
  default = "last_10m"
}

variable "latency_percentile" {
  type = string
  default = "p99"
}

variable "latency_target" {
  type = number
}

variable "slo_latency_target" {
  type = number
}

variable "tags" {
  type = list(string)
  default = []
}

variable "message" {
  type = string
  default = "@slack-figure-alerts"
}

variable "notify_on_missing_data" {
  type = bool
  default = false
}
