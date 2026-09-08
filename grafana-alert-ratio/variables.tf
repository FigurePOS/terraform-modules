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

variable "denominator_metric" {
  type        = string
  description = "Axiom metric name for the denominator (e.g. fgr.delivery.estimation.requested)."
}

variable "env" {
  type        = string
  description = "development or production. Selects Axiom dataset and Slack route (via labels.env)."

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

variable "name" {
  type        = string
  description = "Alert rule title."
}

variable "numerator_metric" {
  type        = string
  description = "Axiom metric name for the numerator (e.g. fgr.delivery.estimation.failed)."
}

variable "panel_id" {
  type        = number
  default     = null
  description = "Grafana panel id for the alert panel link. Pair with dashboard_uid."
}

variable "service_name" {
  type        = string
  description = "OTEL service.name (e.g. fgr-service-delivery)."
}

variable "summary" {
  type        = string
  default     = null
  description = "Optional alert summary. Defaults to name."
}

variable "threshold" {
  type        = number
  description = "Ratio threshold in percent (100 * numerator / denominator)."
}
