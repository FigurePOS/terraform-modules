data "datadog_role" "admin_role" {
  filter = "Admin"
}
resource "datadog_monitor" "ecs_cpu_monitor" {
  name    = "${var.service_name} – ECS – CPU utilization"
  count   = var.env == "production" ? 1 : 0
  type    = "metric alert"
  message = var.message
  query   = "min(${var.interval}):avg:aws.ecs.service.cpuutilization{servicename:${var.service_name},env:${var.env}} > ${var.cpu_critical}"
  monitor_thresholds {
    warning  = var.cpu_warning
    critical = var.cpu_critical
  }

  restricted_roles = [data.datadog_role.admin_role.id]
  tags             = var.tags
}

resource "datadog_monitor" "ecs_memory_monitor" {
  name    = "${var.service_name} – ECS – Memory utilization"
  count   = var.env == "production" ? 1 : 0
  type    = "metric alert"
  message = var.message
  query   = "min(${var.interval}):avg:aws.ecs.service.memory_utilization{servicename:${var.service_name},env:${var.env}} > ${var.memory_critical}"
  monitor_thresholds {
    warning  = var.memory_warning
    critical = var.memory_critical
  }

  restricted_roles = [data.datadog_role.admin_role.id]
  tags             = var.tags
}
