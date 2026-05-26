resource "axiom_monitor" "memory_usage" {
  type             = "Threshold"
  name             = "${var.service_name} – Redis – Memory Usage"
  description      = var.message
  mpl_query        = local.memory_mpl_query
  interval_minutes = var.memory_interval_minutes
  range_minutes    = var.memory_range_minutes
  operator         = "Above"
  threshold        = var.memory_threshold
  notifier_ids     = [data.aws_ssm_parameter.axiom_platform_warnings_notifier_id.value, data.aws_ssm_parameter.axiom_rootly_notifier_id.value]

  alert_on_no_data = var.notify_on_missing_data
  notify_by_group  = false
}

resource "axiom_monitor" "cpu_utilization" {
  type             = "Threshold"
  name             = "${var.service_name} – Redis – CPU Utilization"
  description      = var.message
  mpl_query        = local.cpu_mpl_query
  interval_minutes = var.cpu_interval_minutes
  range_minutes    = var.cpu_range_minutes
  operator         = "Above"
  threshold        = var.cpu_threshold
  notifier_ids     = [data.aws_ssm_parameter.axiom_platform_warnings_notifier_id.value, data.aws_ssm_parameter.axiom_rootly_notifier_id.value]

  alert_on_no_data = var.notify_on_missing_data
  notify_by_group  = false
}
