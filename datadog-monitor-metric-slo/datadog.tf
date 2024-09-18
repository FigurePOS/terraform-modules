module "dd_monitor" {
  source = "../datadog-monitor-metric"

  env  = var.env
  tags = var.tags

  monitor_name          = var.monitor_name
  monitor_message       = var.monitor_message
  monitor_eval_interval = var.monitor_eval_interval
  monitor_eval_fn       = var.monitor_eval_fn
  monitor_query         = var.monitor_query
  warning_threshold     = var.warning_threshold
  critical_threshold    = var.critical_threshold
}


resource "datadog_service_level_objective" "dd_slo" {
  name = var.slo_name
  type = "monitor"
  monitor_ids = [
    module.dd_monitor.monitor_id
  ]
  dynamic "thresholds" {
    for_each = var.slo_thresholds
    content {
      timeframe = thresholds.value.timeframe
      target    = thresholds.value.target
    }
  }

  tags = var.tags
}

