locals {
  dataset    = var.env == "development" ? "node-js-metrics-dev" : "node-js-metrics-prod"
  interval_m = floor(var.interval / 60)
  percentile = tonumber(trimprefix(var.latency_percentile, "p")) / 100
  group_name = "${var.service_name}-events-${var.event_type}-${var.env}"

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
