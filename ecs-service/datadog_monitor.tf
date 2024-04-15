data "datadog_role" "admin_role" {
  filter = "Admin"
}

locals {
  message = "{{#is_warning}}@slack-platform-warnings{{/is_warning}} {{#is_warning_recovery}}@slack-platform-warnings{{/is_warning_recovery}} {{#is_alert}}@opsgenie @slack-alerts{{/is_alert}} {{#is_alert_recovery}}@opsgenie @slack-alerts{{/is_alert_recovery}}"
  tags = ["service:${var.service_name}"]
}

resource "datadog_monitor" "ecs_cpu_monitor" {
  name    = "${var.service_name} – ecs – cpu utilization"
  count   = var.env == "production" ? 1 : 0
  type    = "metric alert"
  message = local.message
  query   = "avg(last_5m):aws.ecs.service.cpuutilization{servicename:${var.service_name},env:${var.env}} > ${var.dd_monitor_cpu_critical}"
  monitor_thresholds {
    warning  = var.dd_monitor_cpu_warning
    critical = var.dd_monitor_cpu_critical
  }

  restricted_roles = [data.datadog_role.admin_role.id]
  tags             = local.tags
}

resource "datadog_monitor" "ecs_memory_monitor" {
  name    = "${var.service_name} – ecs – memory utilization"
  count   = var.env == "production" ? 1 : 0
  type    = "metric alert"
  message = local.message
  query   = "avg(last_5m):aws.ecs.service.memory_utilization{servicename:${var.service_name},env:${var.env}} > ${var.dd_monitor_memory_critical}"
  monitor_thresholds {
    warning  = var.dd_monitor_memory_warning
    critical = var.dd_monitor_memory_critical
  }

  restricted_roles = [data.datadog_role.admin_role.id]
  tags             = local.tags
}
