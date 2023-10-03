data "datadog_role" "admin_role" {
  filter = "Admin"
}

resource "datadog_monitor" "monitor" {
  name    = var.monitor_name
  tags    = var.tags
  type    = "metric alert"
  message = var.monitor_message
  query   = "${var.monitor_eval_fn}(${var.monitor_eval_interval}):${var.monitor_query} > ${var.monitor_threshold}"
  monitor_thresholds {
    warning  = var.monitor_threshold / 2
    critical = var.monitor_threshold
  }

  restricted_roles = [data.datadog_role.admin_role.id]
}

resource "datadog_service_level_objective" "slo" {
  name = var.slo_name
  type = "monitor"
  monitor_ids = [
    datadog_monitor.monitor.id
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

