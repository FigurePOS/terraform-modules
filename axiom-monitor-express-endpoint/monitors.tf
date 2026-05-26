resource "axiom_monitor" "error_rate" {
  type             = "Threshold"
  name             = "${var.service_name} – APM - ${var.resource_name_readable} – Error rate"
  description      = var.message
  apl_query        = local.error_rate_apl_query
  interval_minutes = var.interval_minutes
  range_minutes    = var.range_minutes
  operator         = "Above"
  threshold        = var.error_rate_target
  notifier_ids     = [data.aws_ssm_parameter.axiom_platform_warnings_notifier_id.value]

  alert_on_no_data = var.notify_on_missing_data
  notify_by_group  = false
}

resource "axiom_monitor" "latency" {
  type             = "Threshold"
  name             = "${var.service_name} – APM - ${var.resource_name_readable} – Latency"
  description      = var.message
  apl_query        = local.latency_apl_query
  interval_minutes = var.interval_minutes
  range_minutes    = var.range_minutes
  operator         = "Above"
  threshold        = var.latency_threshold_ms
  notifier_ids     = [data.aws_ssm_parameter.axiom_platform_warnings_notifier_id.value]

  alert_on_no_data = var.notify_on_missing_data
  notify_by_group  = false
}
