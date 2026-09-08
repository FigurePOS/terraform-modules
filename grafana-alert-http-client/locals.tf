locals {
  dataset    = var.env == "development" ? "node-js-metrics-dev" : "node-js-metrics-prod"
  interval_m = floor(var.interval / 60)
  percentile = tonumber(trimprefix(var.latency_percentile, "p")) / 100

  filter_slug = join("-", [for k, v in var.filters : "${k}-${v}"])
  group_name = join("-", compact([
    var.service_name,
    "http-client",
    local.filter_slug != "" ? local.filter_slug : null,
    var.env,
  ]))

  # AMG caps alert queries at 30s (not configurable). One rule per group, 2m eval,
  # KeepLast + pending swallow a single timeout instead of paging DatasourceError.
  eval_interval_seconds = 120
  pending_for           = "2m"
  max_data_points       = max(local.interval_m, 1)

  panel_annotations = var.dashboard_uid != null && var.panel_id != null ? {
    __dashboardUid__ = var.dashboard_uid
    __panelId__      = tostring(var.panel_id)
  } : {}

  rule_labels = merge(var.labels, {
    service = var.service_name
    env     = var.env
  })

  where_clauses = join("\n", concat(
    ["| where `service.name` == \"${var.service_name}\""],
    [for k, v in var.filters : "| where `${k}` == \"${v}\""],
  ))

  # Histogram is recorded in ms via sendTimerMetric; convert to seconds for latency_target.
  latency_query = <<-EOT
    `${local.dataset}`:`fgr.http.client.request`
    ${local.where_clauses}
    | bucket to 1m using interpolate_delta_histogram(${local.percentile})
    | map / 1000
  EOT

  # Same histogram; count rate of error_status_class vs all (Datadog used .count on the timer).
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
  EOT

  rules = {
    error_rate = {
      kind        = "http-client-error-rate"
      name        = "${var.service_name} – ${var.name} – Error rate (${var.env})"
      summary     = "Error rate for ${var.name} is over ${var.error_rate_target}% (${var.env})"
      description = "avg(last_${local.interval_m}m) of 100 * ${var.error_status_class}/all fgr.http.client.request > ${var.error_rate_target}."
      threshold   = var.error_rate_target
      query       = local.error_rate_query
    }
    latency = {
      kind        = "http-client-latency"
      name        = "${var.service_name} – ${var.name} – Latency (${var.env})"
      summary     = "${var.latency_percentile} latency for ${var.name} is over ${var.latency_target}s (${var.env})"
      description = "avg(last_${local.interval_m}m) of ${var.latency_percentile}(fgr.http.client.request)/1000 > ${var.latency_target}s."
      threshold   = var.latency_target
      query       = local.latency_query
    }
  }
}
