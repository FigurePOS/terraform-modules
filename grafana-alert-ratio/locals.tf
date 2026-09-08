locals {
  dataset    = var.env == "development" ? "node-js-metrics-dev" : "node-js-metrics-prod"
  interval_m = floor(var.interval / 60)
  # Rule group names must be unique; slug from service + metrics + filters.
  filter_slug = join("-", [for k, v in var.filters : "${k}-${v}"])
  group_name = join("-", compact([
    var.service_name,
    "ratio",
    replace(var.numerator_metric, ".", "-"),
    local.filter_slug != "" ? local.filter_slug : null,
    var.env,
  ]))

  # AMG caps alert queries at 30s (not configurable). 2m eval + KeepLast + pending
  # swallow a single timeout instead of paging DatasourceError.
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

  # service.name always; then caller filters (e.g. resource == doordash).
  where_clauses = join("\n", concat(
    ["| where `service.name` == \"${var.service_name}\""],
    [for k, v in var.filters : "| where `${k}` == \"${v}\""],
  ))

  ratio_query = <<-EOT
    (
      `${local.dataset}`:`${var.numerator_metric}`
      ${local.where_clauses}
      | map rate
      | align to 1m using avg
      | group using sum,
      `${local.dataset}`:`${var.denominator_metric}`
      ${local.where_clauses}
      | map rate
      | align to 1m using avg
      | group using sum
    )
    | compute ratio_pct using /
    | map * 100
  EOT

  summary = var.summary != null ? var.summary : var.name
}
