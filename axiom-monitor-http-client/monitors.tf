resource "axiom_monitor" "error_rate" {
  type                = "Threshold"
  name                = "${var.service_name} – ${var.name} – Error rate (${var.env})"
  description         = local.error_rate_summary
  mpl_query           = local.error_rate_query
  interval_minutes    = var.interval_minutes
  range_minutes       = local.range_minutes
  operator            = "Above"
  threshold           = var.error_rate_target
  notifier_ids        = local.notifier_ids
  alert_on_no_data    = var.notify_on_missing_data
  notify_by_group     = false
  trigger_from_n_runs = local.trigger_from_n_runs
}

resource "axiom_monitor" "latency" {
  type                = "Threshold"
  name                = "${var.service_name} – ${var.name} – Latency (${var.env})"
  description         = local.latency_summary
  mpl_query           = local.latency_query
  interval_minutes    = var.interval_minutes
  range_minutes       = local.range_minutes
  operator            = "Above"
  threshold           = var.latency_target
  notifier_ids        = local.notifier_ids
  alert_on_no_data    = var.notify_on_missing_data
  notify_by_group     = false
  trigger_from_n_runs = local.trigger_from_n_runs
}
