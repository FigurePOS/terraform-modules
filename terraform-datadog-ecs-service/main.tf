
resource "datadog_monitor" "ecs_cpu_monitor" {
  name = "${var.service_name_readable} – ECS – CPU utilization"
  count = var.env == "production" ? 1 : 0
  type = "metric alert"
  message = var.message
  query = "avg(${var.interval}):avg:aws.ecs.service.cpuutilization.maximum{servicename:${var.service_name},env:${var.env}} > ${var.cpu_critical}"
  monitor_thresholds {
    warning = var.cpu_warning
    critical = var.cpu_critical
  }
  locked = true
  tags = var.tags
}

resource "datadog_monitor" "ecs_memory_monitor" {
  name = "${var.service_name_readable} – ECS – Memory utilization"
  count = var.env == "production" ? 1 : 0
  type = "metric alert"
  message = var.message
  query = "avg(${var.interval}):avg:aws.ecs.service.memory_utilization.maximum{servicename:${var.service_name},env:${var.env}} > ${var.memory_critical}"
  monitor_thresholds {
    warning = var.memory_warning
    critical = var.memory_critical
  }
  locked = true
  tags = var.tags
}