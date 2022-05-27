
locals {
  monitor_dimensions = "env:${var.env},resource_name:${lower(var.resource_name)},service:${var.service}"
  metric_latency = "${var.latency_percentile}:trace.figure.message.consumer{${local.monitor_dimensions}}"
}

resource "datadog_monitor" "apm_monitor_latency" {
  name = "${var.service_name_readable} – APM - ${var.resource_name_readable} – Latency (${var.latency_percentile}) is over ${var.latency_target}s"
  count = var.env == "production" ? 1 : 0
  type = "metric alert"
  message = var.message
  query = "min(${var.interval}):${local.metric_latency} > ${var.latency_target}"
  tags = var.tags
  locked = true
  notify_no_data = var.notify_on_missing_data
}

resource "datadog_service_level_objective" "apm_slo_latency" {
  name = "${var.service_name_readable} – APM - ${var.resource_name_readable} – Latency"
  count = var.env == "production" ? 1 : 0
  type = "monitor"
  monitor_ids = [
    datadog_monitor.apm_monitor_latency[0].id
  ]
  thresholds {
    timeframe = "30d"
    target = var.slo_latency_target
  }
  thresholds {
    timeframe = "90d"
    target = var.slo_latency_target
  }
  tags = var.tags
}

