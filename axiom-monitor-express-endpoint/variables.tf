variable "endpoint" {
  type        = string
  description = "Trace resource.name value, e.g. POST /business-config/category/match"
}

variable "env" {
  type = string
}

variable "error_rate_target" {
  type        = number
  description = "Error rate threshold in percent"
}

variable "interval_minutes" {
  type        = number
  default     = 5
  description = "How often the monitor runs, in minutes"
}

variable "latency_percentile" {
  type        = number
  default     = 99
  description = "Latency percentile to evaluate, e.g. 99 for p99"
}

variable "latency_threshold_ms" {
  type        = number
  default     = 1
  description = "Latency threshold in millsiseconds"
}

variable "message" {
  type    = string
  default = "Platform warnings Slack channel"
}

variable "notify_on_missing_data" {
  type    = bool
  default = false
}

variable "range_minutes" {
  type        = number
  default     = 10
  description = "Axiom monitor query lookback window in minutes"
}

variable "resource_name_readable" {
  type = string
}

variable "service_name" {
  type = string
}
