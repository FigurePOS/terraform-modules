resource "axiom_monitor" "ratio" {
  type                = "Threshold"
  name                = var.name
  description         = local.summary
  mpl_query           = local.ratio_query
  interval_minutes    = local.eval_interval_minutes
  range_minutes       = local.interval_m
  operator            = "Above"
  threshold           = var.threshold
  notifier_ids        = local.notifier_ids
  alert_on_no_data    = var.notify_on_missing_data
  notify_by_group     = false
  trigger_from_n_runs = local.trigger_from_n_runs
}
