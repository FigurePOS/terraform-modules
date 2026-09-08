resource "axiom_monitor" "latency" {
  type                = "Threshold"
  name                = "${var.service_name} – Events - ${var.event_type} – Latency (${var.env})"
  description         = local.latency_summary
  mpl_query           = local.latency_query
  interval_minutes    = local.eval_interval_minutes
  range_minutes       = local.interval_m
  operator            = "Above"
  threshold           = var.latency_target
  notifier_ids        = local.notifier_ids
  alert_on_no_data    = var.notify_on_missing_data
  notify_by_group     = false
  trigger_from_n_runs = local.trigger_from_n_runs
}
