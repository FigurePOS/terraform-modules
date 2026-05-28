
variable "api_path_prefix" {
  type        = string
  description = "ALB mount prefix without slashes (e.g. business-config). Combined with route for http.route tag."
}

variable "env" {
  type = string
}

variable "error_rate_eval_fn" {
  type        = string
  default     = "avg"
  description = "Time aggregation for the error-rate monitor (e.g. avg, max, min)."
}

variable "error_rate_target" {
  type = number
}

variable "interval" {
  type    = string
  default = "last_10m"
}

variable "latency_eval_fn" {
  type        = string
  default     = "max"
  description = "Time aggregation for the latency monitor (e.g. avg, max, min)."
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

variable "method" {
  type        = string
  description = "HTTP method (GET, POST, etc.). Normalized to uppercase in monitor queries."
}

variable "notify_on_missing_data" {
  type    = bool
  default = false
}

variable "route" {
  type        = string
  description = "Route path with leading slash, without api_path_prefix (e.g. /category/match, /location/:id)."

  validation {
    condition     = startswith(var.route, "/")
    error_message = "route must start with / (e.g. /category/match)."
  }
}

variable "service_name" {
  type = string
}

variable "tags" {
  type        = list(string)
  default     = []
  description = "Additional Datadog monitor tags. An env:<environment> tag is always included from var.env."
}
