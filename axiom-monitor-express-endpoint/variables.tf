variable "env" {
  type        = string
  description = "Application environment (development/production). Monitors are only created in production."

  validation {
    condition     = contains(["development", "production"], var.env)
    error_message = "env must be 'development' or 'production'."
  }
}

variable "service_name" {
  type        = string
  description = "Service name matching the OTEL resource attribute 'service.name'."
}

variable "span_name" {
  type        = string
  description = "Express span name to filter on (e.g. 'GET /orders/:id'). Matches the OTEL span 'name' field set by the Express instrumentation."
}

variable "span_name_readable" {
  type        = string
  description = "Human-readable label for the monitored endpoint used in monitor names (e.g. 'GET /orders/:id')."
}

variable "error_rate_target" {
  type        = number
  description = "Error rate threshold in percent (0–100) that triggers the error rate monitor."
}

variable "latency_target" {
  type        = number
  description = "Latency threshold in milliseconds that triggers the latency monitor."
}

variable "latency_percentile" {
  type        = number
  default     = 99
  description = "Percentile used for the latency monitor query (e.g. 99 for p99). Default: 99."

  validation {
    condition     = var.latency_percentile > 0 && var.latency_percentile < 100
    error_message = "latency_percentile must be between 1 and 99."
  }
}

variable "interval_minutes" {
  type        = number
  default     = 5
  description = "How often the monitor runs, in minutes. Default: 5."
}

variable "range_minutes" {
  type        = number
  default     = 10
  description = "Lookback window used by the APL query, in minutes. Default: 10."
}

variable "notifier_ids" {
  type        = list(string)
  default     = []
  description = "List of Axiom notifier IDs to alert when the monitor fires."
}

variable "notify_on_missing_data" {
  type        = bool
  default     = false
  description = "Whether the latency monitor should fire when no trace data is present. Default: false."
}
