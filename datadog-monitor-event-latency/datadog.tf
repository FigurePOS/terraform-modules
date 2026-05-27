
locals {
  slack_warning_handle = var.env == "development" ? "@slack-platform-warnings-dev" : "@slack-platform-warnings"
  monitor_message      = coalesce(var.message, local.slack_warning_handle)

  monitor_dimensions = "env:${var.env},resource_name:${var.resource_name},service:${var.service_name}"
  metric_latency     = "${var.latency_percentile}:fgr.message.consumer.duration{${local.monitor_dimensions}}"

  monitor_tags = concat(["env:${var.env}", "service:${var.service_name}"], var.tags)
}

data "datadog_role" "admin_role" {
  filter = "Admin"
}

resource "datadog_monitor" "event_monitor_latency" {
  name           = "${var.service_name} – Events - ${var.resource_name} – Latency"
  type           = "metric alert"
  message        = local.monitor_message
  query          = "${var.eval_fn}(${var.interval}):${local.metric_latency} > ${var.latency_target}"
  notify_no_data = var.notify_on_missing_data

  restricted_roles = [data.datadog_role.admin_role.id]
  tags             = local.monitor_tags
}
