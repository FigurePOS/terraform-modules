locals {
  method_upper  = upper(var.method)
  resource_name = "${local.method_upper} /${var.api_path_prefix}${var.route}"
  dataset       = var.env == "development" ? "node-js-metrics-dev" : "node-js-metrics-prod"
  interval_m    = max(floor(var.interval / 60), 1)
  percentile    = tonumber(trimprefix(var.latency_percentile, "p")) / 100

  # Same cadence as grafana-alert-*: 2m eval, 2 consecutive runs (~ Grafana for = 2m).
  eval_interval_minutes = 2
  trigger_from_n_runs   = 2
  notifier_ids          = var.notifier_ids != null ? var.notifier_ids : [data.aws_ssm_parameter.axiom_platform_warnings_notifier_id[0].value]

  error_rate_summary = "Error rate for ${local.method_upper} ${var.route} is over ${var.error_rate_target}% (${var.env})"
  latency_summary    = "${var.latency_percentile} latency for ${local.method_upper} ${var.route} is over ${var.latency_target}s (${var.env})"

  error_rate_query = <<-EOT
    (
      `${local.dataset}`:`fgr.http.server.request.errors`
      | where `service.name` == "${var.service_name}"
      | where `resource.name` == "${local.resource_name}"
      | map rate
      | align to 1m using avg
      | group using sum,
      `${local.dataset}`:`fgr.http.server.request.count`
      | where `service.name` == "${var.service_name}"
      | where `resource.name` == "${local.resource_name}"
      | map rate
      | align to 1m using avg
      | group using sum
    )
    | compute error_pct using /
    | map * 100
  EOT

  latency_query = <<-EOT
    `${local.dataset}`:`fgr.http.server.request.duration`
    | where `service.name` == "${var.service_name}"
    | where `resource.name` == "${local.resource_name}"
    | bucket to 1m using interpolate_delta_histogram(${local.percentile})
  EOT
}
