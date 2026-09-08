variable "denominator_metric" {
  type        = string
  description = "Axiom metric name for the denominator (e.g. fgr.delivery.estimation.requested)."
}

variable "env" {
  type        = string
  description = "development or production. Selects Axiom dataset. Slack notifier SSM is env-scoped in aws/app."

  validation {
    condition     = contains(["development", "production"], var.env)
    error_message = "env must be development or production."
  }
}

variable "filters" {
  type        = map(string)
  default     = {}
  description = "Extra metric attribute filters applied to both numerator and denominator (e.g. { resource = \"doordash\" }). service.name is always filtered."
}

variable "interval" {
  type        = number
  default     = 300
  description = "Lookback window in seconds (Axiom range_minutes). Default 5m, same as grafana-alert-ratio."
}

variable "name" {
  type        = string
  description = "Monitor title."
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

variable "numerator_metric" {
  type        = string
  description = "Axiom metric name for the numerator (e.g. fgr.delivery.estimation.failed)."
}

variable "service_name" {
  type        = string
  description = "OTEL service.name (e.g. fgr-service-delivery)."
}

variable "summary" {
  type        = string
  default     = null
  description = "Optional monitor description. Defaults to name."
}

variable "threshold" {
  type        = number
  description = "Ratio threshold in percent (100 * numerator / denominator)."
}
