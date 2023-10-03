
locals {
  monitor_dimensions = "env:${var.env},resource_name:${lower(var.resource_name)},service:${var.service}"
  metric_errors      = "sum:trace.express.request.errors{${local.monitor_dimensions}}.as_rate().rollup(sum,60)"
  metric_hits        = "sum:trace.express.request.hits{${local.monitor_dimensions}}.as_rate().rollup(sum,60)"
  metric_latency     = "${var.latency_percentile}:trace.express.request{${local.monitor_dimensions}}"
}

data "datadog_role" "admin_role" {
  filter = "Admin"
}

resource "datadog_monitor" "apm_monitor_error_rate" {
  name    = "${var.service_name} – APM - ${var.resource_name} – Error rate is over ${var.error_rate_target}%"
  count   = var.env == "production" ? 1 : 0
  type    = "metric alert"
  message = var.message
  query   = "${var.eval_fn}(${var.interval}):(100 * ${local.metric_errors} / ${local.metric_hits}) > ${var.error_rate_target}"

  restricted_roles = [data.datadog_role.admin_role.id]
  tags             = var.tags
}

resource "datadog_service_level_objective" "apm_slo_error_rate" {
  name  = "${var.service_name} – APM - ${var.resource_name} – Error rate"
  count = var.env == "production" ? 1 : 0
  type  = "monitor"
  monitor_ids = [
    datadog_monitor.apm_monitor_error_rate[0].id
  ]
  thresholds {
    timeframe = "30d"
    target    = var.slo_error_rate_target
  }
  thresholds {
    timeframe = "90d"
    target    = var.slo_error_rate_target
  }

  tags = var.tags
}

resource "datadog_monitor" "apm_monitor_latency" {
  name           = "${var.service_name} – APM - ${var.resource_name} – Latency (${var.latency_percentile}) is over ${var.latency_target}s"
  count          = var.env == "production" ? 1 : 0
  type           = "metric alert"
  message        = var.message
  query          = "${var.eval_fn}(${var.interval}):${local.metric_latency} > ${var.latency_target}"
  notify_no_data = var.notify_on_missing_data

  restricted_roles = [data.datadog_role.admin_role.id]
  tags             = var.tags
}

resource "datadog_service_level_objective" "apm_slo_latency" {
  name  = "${var.service_name} – APM - ${var.resource_name} – Latency"
  count = var.env == "production" ? 1 : 0
  type  = "monitor"
  monitor_ids = [
    datadog_monitor.apm_monitor_latency[0].id
  ]
  thresholds {
    timeframe = "30d"
    target    = var.slo_latency_target
  }
  thresholds {
    timeframe = "90d"
    target    = var.slo_latency_target
  }

  tags = var.tags
}

