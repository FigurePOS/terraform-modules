data "datadog_role" "admin_role" {
  filter = "Admin"
}

locals {
  oncall_handle        = "@webhook-rootly"
  slack_warning_handle = "@slack-platform-warnings"

  message = "{{#is_alert}}${local.oncall_handle}{{/is_alert}} {{#is_alert_recovery}}${local.oncall_handle}{{/is_alert_recovery}} ${local.slack_warning_handle}"
  tags    = ["service:${var.service_name}"]
}

resource "datadog_monitor" "ecs_cpu_monitor" {
  count = var.env == "production" ? 1 : 0

  name    = "${var.service_name} – ecs – cpu utilization"
  type    = "metric alert"
  message = local.message
  query   = "avg(last_5m):aws.ecs.service.cpuutilization{servicename:${var.service_name},env:${var.env}}.rollup(avg, 600) > ${var.dd_monitor_cpu_critical}"
  monitor_thresholds {
    warning  = var.dd_monitor_cpu_warning
    critical = var.dd_monitor_cpu_critical
  }

  restricted_roles = [data.datadog_role.admin_role.id]
  tags             = local.tags
}

resource "datadog_monitor" "ecs_memory_monitor" {
  count = var.env == "production" ? 1 : 0

  name    = "${var.service_name} – ecs – memory utilization"
  type    = "metric alert"
  message = local.message
  query   = "avg(last_5m):aws.ecs.service.memory_utilization{servicename:${var.service_name},env:${var.env}}.rollup(avg, 600) > ${var.dd_monitor_memory_critical}"
  monitor_thresholds {
    warning  = var.dd_monitor_memory_warning
    critical = var.dd_monitor_memory_critical
  }

  restricted_roles = [data.datadog_role.admin_role.id]
  tags             = local.tags
}
