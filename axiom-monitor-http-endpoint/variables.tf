variable "api_path_prefix" {
  type        = string
  description = "ALB mount prefix without slashes (e.g. payments). Combined with route for OTEL resource.name."
}

variable "env" {
  type        = string
  description = "development or production. Selects Axiom dataset. Slack notifier SSM is env-scoped in aws/app."

  validation {
    condition     = contains(["development", "production"], var.env)
    error_message = "env must be development or production."
  }
}

variable "error_rate_target" {
  type        = number
  description = "Error rate threshold in percent."
}

variable "interval" {
  type        = number
  default     = 300
  description = "Lookback window in seconds (Axiom range_minutes). Default 5m, same as grafana-alert-http-endpoint."
}

variable "latency_percentile" {
  type        = string
  default     = "p95"
  description = "Latency percentile (p95, p99). Converted to 0.95 / 0.99 for Axiom interpolate_delta_histogram."

  validation {
    condition     = can(regex("^p[0-9]+$", var.latency_percentile))
    error_message = "latency_percentile must look like p95 or p99."
  }
}

variable "latency_target" {
  type        = number
  description = "Latency threshold in seconds (matches fgr.http.server.request.duration unit)."
}

variable "method" {
  type        = string
  description = "HTTP method (GET, POST, etc.). Used in monitor title and resource.name filter."
}

variable "notifier_ids" {
  type        = list(string)
  default     = null
  description = "Slack notifier IDs. Default: SSM /axiom/platform_warnings_notifier_id. Pass axiom_notifier ids when applying from infrastructure/axiom."
}

variable "notify_on_missing_data" {
  type        = bool
  default     = false
  description = "If true, Axiom alerts when the query returns no data."
}

variable "route" {
  type        = string
  description = "Route path with leading slash, without api_path_prefix (e.g. /payment/:id)."

  validation {
    condition     = startswith(var.route, "/")
    error_message = "route must start with / (e.g. /category/match)."
  }
}

variable "service_name" {
  type        = string
  description = "OTEL service.name (e.g. fgr-service-payments)."
}
