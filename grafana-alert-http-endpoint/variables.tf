variable "api_path_prefix" {
  type        = string
  description = "ALB mount prefix without slashes (e.g. payments). Combined with route for OTEL resource.name."
}

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
  description = "Error rate threshold in percent."
}

variable "folder_uid" {
  type        = string
  default     = "fgr-services"
  description = "Grafana folder UID for the rule group."
}

variable "interval" {
  type        = number
  default     = 600
  description = "Eval window in seconds (Grafana relative_time_range.from). Datadog last_10m = 600."
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
  description = "Latency threshold in seconds (matches fgr.http.server.request.duration unit)."
}

variable "method" {
  type        = string
  description = "HTTP method (GET, POST, etc.). Used in rule title and resource.name filter."
}

variable "panel_id" {
  type        = number
  default     = null
  description = "Grafana panel id for the alert panel link. Pair with dashboard_uid."
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
