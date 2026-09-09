variable "env" {
  type        = string
  description = "development or production. Selects Axiom dataset. Slack notifier SSM is env-scoped in aws/app."

  validation {
    condition     = contains(["development", "production"], var.env)
    error_message = "env must be development or production."
  }
}

variable "event_type" {
  type        = string
  description = "SQS event name (OTEL resource.name as-is, e.g. OrderPlaced). Not Datadog's lowercased tag."
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
  description = "Latency threshold in seconds (matches fgr.message.consumer.duration unit)."
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
  description = "OTEL service.name (often the worker, e.g. fgr-service-orders-worker)."
}
