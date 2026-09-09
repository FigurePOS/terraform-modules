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
  description = "Error rate threshold in percent (100 * 5xx / all client requests)."
}

variable "error_status_class" {
  type        = string
  default     = "5xx"
  description = "http_status_class attribute value treated as errors (numerator)."
}

variable "filters" {
  type        = map(string)
  default     = {}
  description = "Extra metric attribute filters (e.g. { type = \"payment_gateway\", service = \"CardPointe\" }). service.name is always filtered. Note: attribute `service` is the remote client id, not OTEL service.name."
}

variable "interval" {
  type        = number
  default     = 600
  description = "Lookback window in seconds (Axiom range_minutes). Default 10m."
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
  description = "Latency threshold in seconds. Metric fgr.http.client.request is recorded in ms; the query converts to seconds."
}

variable "name" {
  type        = string
  description = "Short label for monitor titles (e.g. \"CardPointe gateway\")."
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

variable "service_name" {
  type        = string
  description = "OTEL service.name of the calling service (e.g. fgr-service-payments)."
}
