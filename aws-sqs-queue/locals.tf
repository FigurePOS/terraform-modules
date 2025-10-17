locals {
  cloudwatch_count  = var.enable_cloudwatch_alarms && var.env == "production" ? 1 : 0
  alarm_name_prefix = "${var.service_name} SQS"
  tags              = merge(var.tags, { Service = var.service_name })
}
