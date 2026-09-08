variable "axiom_datasource_uid" {
  type        = string
  default     = "axiom"
  description = "Grafana Axiom datasource UID. Datasource itself lives in aws/monitoring."
}

variable "dashboard_uid" {
  type        = string
  default     = null
  description = "Grafana dashboard UID for the alert panel link. Pair with panel_id."
}

variable "env" {
  type        = string
  description = "development or production. Selects Axiom dataset and Slack route (via labels.env)."

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

variable "folder_uid" {
  type        = string
  default     = "fgr-services"
  description = "Grafana folder UID for the rule group."
}

variable "interval" {
  type        = number
  default     = 300
  description = "Lookback window in seconds (Grafana relative_time_range.from). Default 5m; keep small so AMG's 30s Axiom query timeout holds."
}

variable "labels" {
  type        = map(string)
  default     = {}
  description = "Extra Grafana labels (e.g. team). env, service, and kind are always set."
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
  description = "Short label for rule titles (e.g. \"CardPointe gateway\")."
}

variable "panel_id" {
  type        = number
  default     = null
  description = "Grafana panel id for the alert panel link. Pair with dashboard_uid."
}

variable "service_name" {
  type        = string
  description = "OTEL service.name of the calling service (e.g. fgr-service-payments)."
}
