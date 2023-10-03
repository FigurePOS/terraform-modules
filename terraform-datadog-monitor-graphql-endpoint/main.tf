
locals {
  count              = var.env == "production" ? 1 : 0
  monitor_dimensions = "env:${var.env},resource_name:${lower(var.resource_name)},service:${var.service}"
  metric_errors      = "sum:trace.graphql.execute.errors{${local.monitor_dimensions}}.as_rate().rollup(sum,60)"
  metric_hits        = "sum:trace.graphql.execute.hits{${local.monitor_dimensions}}.as_rate().rollup(sum,60)"
  metric_latency     = "${var.latency_percentile}:trace.graphql.execute{${local.monitor_dimensions}}"
}

data "datadog_role" "admin_role" {
  filter = "Admin"
}

resource "datadog_monitor" "apm_monitor_error_rate" {
  count = local.count

  name    = "${var.service_name} – APM - ${var.resource_name} – Error rate"
  type    = "metric alert"
  message = var.message
  query   = "${var.eval_fn}(${var.interval}):(100 * ${local.metric_errors} / ${local.metric_hits}) > ${var.error_rate_target}"

  restricted_roles = [data.datadog_role.admin_role.id]
  tags             = var.tags
}

resource "datadog_monitor" "apm_monitor_latency" {
  count = local.count

  name           = "${var.service_name} – APM - ${var.resource_name} – Latency"
  type           = "metric alert"
  message        = var.message
  query          = "${var.eval_fn}(${var.interval}):${local.metric_latency} > ${var.latency_target}"
  notify_no_data = var.notify_on_missing_data

  restricted_roles = [data.datadog_role.admin_role.id]
  tags             = var.tags
}
