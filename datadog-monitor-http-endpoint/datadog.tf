
locals {
  slack_warning_handle = var.env == "development" ? "@slack-platform-warnings-dev" : "@slack-platform-warnings"
  monitor_message      = coalesce(var.message, local.slack_warning_handle)

  method_upper        = upper(var.method)
  resource_name_label = "${local.method_upper} ${var.route}"
  http_route          = "/${var.api_path_prefix}${var.route}"

  # Datadog indexes OTLP HTTP metrics by http.method and http.route, not resource.name.
  monitor_dimensions = join(",", [
    "env:${var.env}",
    "http.method:${local.method_upper}",
    "http.route:${local.http_route}",
    "service:${var.service_name}",
  ])
  metric_errors       = "sum:fgr.http.server.request.errors{${local.monitor_dimensions}}.as_rate().rollup(sum,60)"
  metric_hits         = "sum:fgr.http.server.request.count{${local.monitor_dimensions}}.as_rate().rollup(sum,60)"
  metric_latency      = "${var.latency_percentile}:fgr.http.server.request.duration{${local.monitor_dimensions}}"

  monitor_tags = concat(["env:${var.env}", "service:${var.service_name}"], var.tags)
}

data "datadog_role" "admin_role" {
  filter = "Admin"
}

resource "datadog_monitor" "http_monitor_error_rate" {
  name    = "${var.service_name} – HTTP - ${local.resource_name_label} - Error rate"
  type    = "metric alert"
  message = local.monitor_message
  query   = "${var.error_rate_eval_fn}(${var.interval}):(100 * ${local.metric_errors} / ${local.metric_hits}) > ${var.error_rate_target}"

  restricted_roles = [data.datadog_role.admin_role.id]
  tags             = local.monitor_tags
}

resource "datadog_monitor" "http_monitor_latency" {
  name           = "${var.service_name} – HTTP - ${local.resource_name_label} - Latency"
  type           = "metric alert"
  message        = local.monitor_message
  query          = "${var.latency_eval_fn}(${var.interval}):${local.metric_latency} > ${var.latency_target}"
  notify_no_data = var.notify_on_missing_data

  restricted_roles = [data.datadog_role.admin_role.id]
  tags             = local.monitor_tags
}
