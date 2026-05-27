data "datadog_role" "admin_role" {
  filter = "Admin"
}

locals {
  monitor_tags = concat(["env:${var.env}", "service:${var.service_name}"], var.tags)
}

resource "datadog_monitor" "monitor" {
  name    = var.monitor_name
  type    = "metric alert"
  message = var.monitor_message
  query   = "${var.monitor_eval_fn}(${var.monitor_eval_interval}):${var.monitor_query} > ${var.critical_threshold}"
  monitor_thresholds {
    warning  = var.warning_threshold != null ? var.warning_threshold : var.critical_threshold / 2
    critical = var.critical_threshold
  }

  restricted_roles = [data.datadog_role.admin_role.id]
  tags             = local.monitor_tags
}

output "monitor_id" {
  value = datadog_monitor.monitor[0].id
}


