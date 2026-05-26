locals {
  metrics_dataset = "node-js-metrics-${var.env == "production" ? "prod" : "dev"}"

  metric_filter = "| where fgr_service_name == \"${var.service_name}\""

  memory_mpl_query = "`${local.metrics_dataset}`:`aws.elasticache.database_memory_usage_percentage.avg`\n${local.metric_filter}\n| align to ${var.memory_align_minutes}m using avg"

  cpu_mpl_query = "`${local.metrics_dataset}`:`aws.elasticache.engine_cpuutilization.avg`\n${local.metric_filter}\n| align to ${var.cpu_align_minutes}m using avg"
}
