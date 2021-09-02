
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

variable "interval" {
  type = string
  default = "last_10m"
}

variable "error_rate_target" {
  type = number
}

variable "latency_percentile" {
  type = string
}

variable "latency_target" {
  type = number
}

variable "slo_error_rate_target" {
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
