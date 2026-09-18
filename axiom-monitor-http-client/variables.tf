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
  default     = null
  description = "Deprecated. Lookback in seconds. Use range_minutes. Ignored if range_minutes is set."

  validation {
    condition     = var.interval == null || (var.interval >= 900 && var.interval % 60 == 0)
    error_message = "interval must be a multiple of 60 and at least 900 (15m). Prefer range_minutes."
  }
}

variable "interval_minutes" {
  type        = number
  default     = 2
  description = "How often the monitor runs (Axiom interval_minutes)."

  validation {
    condition     = var.interval_minutes >= 1 && var.interval_minutes == floor(var.interval_minutes)
    error_message = "interval_minutes must be an integer of at least 1."
  }
}

variable "range_minutes" {
  type        = number
  default     = null
  description = "Lookback window in minutes (Axiom range_minutes). Default 15. Final avg window is range_minutes - 5 so Axiom has a complete clock-aligned bucket."

  validation {
    condition     = var.range_minutes == null || (var.range_minutes >= 15 && var.range_minutes == floor(var.range_minutes))
    error_message = "range_minutes must be an integer of at least 15."
  }
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
