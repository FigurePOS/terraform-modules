locals {
  dataset    = var.env == "development" ? "node-js-metrics-dev" : "node-js-metrics-prod"
  interval_m = max(floor(var.interval / 60), 1)
  percentile = tonumber(trimprefix(var.latency_percentile, "p")) / 100

  eval_interval_minutes = 2
  trigger_from_n_runs   = 2
  notifier_ids          = var.notifier_ids != null ? var.notifier_ids : [data.aws_ssm_parameter.axiom_platform_warnings_notifier_id[0].value]

  error_rate_summary = "Error rate for ${var.name} is over ${var.error_rate_target}% (${var.env})"
  latency_summary    = "${var.latency_percentile} latency for ${var.name} is over ${var.latency_target}s (${var.env})"

  where_clauses = join("\n", concat(
    ["| where `service.name` == \"${var.service_name}\""],
    [for k, v in var.filters : "| where `${k}` == \"${v}\""],
  ))

  # Omit `to <window>` so the histogram is over the full monitor range (one value).
  # `bucket to 1m` + range_minutes=10 is rejected by Axiom: "range too short for the bin size".
  latency_query = <<-EOT
    `${local.dataset}`:`fgr.http.client.request`
    ${local.where_clauses}
    | bucket using interpolate_delta_histogram(${local.percentile})
    | map / 1000
  EOT

  error_rate_query = <<-EOT
    (
      `${local.dataset}`:`fgr.http.client.request`
      ${local.where_clauses}
      | where `http_status_class` == "${var.error_status_class}"
      | map rate
      | align to 1m using avg
      | group using sum,
      `${local.dataset}`:`fgr.http.client.request`
      ${local.where_clauses}
      | map rate
      | align to 1m using avg
      | group using sum
    )
    | compute error_pct using /
    | map * 100
    | align using avg
  EOT
}
