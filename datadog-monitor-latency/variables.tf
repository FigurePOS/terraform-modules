
variable "env" {
  type = string
}

variable "resource_name" {
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
  default = "@slack-platform-warnings"
}

variable "notify_on_missing_data" {
  type = bool
  default = false
}
