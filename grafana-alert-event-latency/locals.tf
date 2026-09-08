locals {
  dataset    = var.env == "development" ? "node-js-metrics-dev" : "node-js-metrics-prod"
  interval_m = floor(var.interval / 60)
  percentile = tonumber(trimprefix(var.latency_percentile, "p")) / 100
  group_name = "${var.service_name}-events-${var.event_type}-${var.env}"

  # AMG caps alert queries at 30s (not configurable). 2m eval + KeepLast + pending
  # swallow a single timeout instead of paging DatasourceError.
  eval_interval_seconds = 120
  pending_for           = "2m"
  max_data_points       = max(local.interval_m, 1)

  panel_annotations = var.dashboard_uid != null && var.panel_id != null ? {
    __dashboardUid__ = var.dashboard_uid
    __panelId__      = tostring(var.panel_id)
  } : {}

  latency_query = <<-EOT
    `${local.dataset}`:`fgr.message.consumer.duration`
    | where `service.name` == "${var.service_name}"
    | where `resource.name` == "${var.event_type}"
    | bucket to 1m using interpolate_delta_histogram(${local.percentile})
  EOT
}
