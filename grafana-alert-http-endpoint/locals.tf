locals {
  method_upper  = upper(var.method)
  resource_name = "${local.method_upper} /${var.api_path_prefix}${var.route}"
  dataset       = var.env == "development" ? "node-js-metrics-dev" : "node-js-metrics-prod"
  interval_m    = floor(var.interval / 60)
  percentile    = tonumber(trimprefix(var.latency_percentile, "p")) / 100
  route_slug    = trim(replace(replace(var.route, "/", "-"), ":", ""), "-")
  group_name    = "${var.service_name}-http-${local.method_upper}-${local.route_slug}-${var.env}"

  panel_annotations = var.dashboard_uid != null && var.panel_id != null ? {
    __dashboardUid__ = var.dashboard_uid
    __panelId__      = tostring(var.panel_id)
  } : {}

  rule_labels = merge(var.labels, {
    service = var.service_name
    env     = var.env
  })

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

  rules = {
    error_rate = {
      kind        = "http-error-rate"
      name        = "${var.service_name} – HTTP - ${local.method_upper} ${var.route} - Error rate (${var.env})"
      summary     = "Error rate for ${local.method_upper} ${var.route} is over ${var.error_rate_target}% (${var.env})"
      description = "avg(last_${local.interval_m}m) of 100 * errors/hits > ${var.error_rate_target}."
      threshold   = var.error_rate_target
      query       = local.error_rate_query
    }
    latency = {
      kind        = "http-latency"
      name        = "${var.service_name} – HTTP - ${local.method_upper} ${var.route} - Latency (${var.env})"
      summary     = "${var.latency_percentile} latency for ${local.method_upper} ${var.route} is over ${var.latency_target}s (${var.env})"
      description = "avg(last_${local.interval_m}m) of ${var.latency_percentile}(fgr.http.server.request.duration) > ${var.latency_target}s."
      threshold   = var.latency_target
      query       = local.latency_query
    }
  }
}
