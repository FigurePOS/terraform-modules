
variable "env" {
  type = string
}

variable "error_rate_target" {
  type = number
}

variable "eval_fn" {
  type    = string
  default = "min"
}

variable "interval" {
  type    = string
  default = "last_10m"
}

variable "latency_percentile" {
  type    = string
  default = "p99"
}

variable "latency_target" {
  type        = number
  description = "Latency threshold in seconds (matches fgr.http.server.request.duration unit)."
}

variable "message" {
  type        = string
  default     = null
  description = "Datadog monitor notification message. Defaults to @slack-platform-warnings-dev in development, @slack-platform-warnings otherwise."
}

variable "notify_on_missing_data" {
  type    = bool
  default = false
}

variable "resource_name" {
  type        = string
  description = "OTLP resource.name tag value for the route (e.g. POST /orders/order/v3). Must match lib-observability HTTP metrics."
}

variable "resource_name_readable" {
  type        = string
  description = "Short human-readable route label used in the Datadog monitor title (e.g. POST /order/v3)."
}

variable "service_name" {
  type = string
}

variable "tags" {
  type        = list(string)
  default     = []
  description = "Additional Datadog monitor tags. An env:<environment> tag is always included from var.env."
}
