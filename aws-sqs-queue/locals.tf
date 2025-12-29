locals {
  cloudwatch_count  = var.enable_cloudwatch_alarms && var.env == "production" ? 1 : 0
  alarm_name_prefix = "${var.service_name} SQS"
  tags              = merge(var.tags, { Service = var.service_name })
  
  # Hardcoded SNS topic ARN for Slack alerts (shared across all accounts)
  # Returns a list for compatibility with alarm_actions which expects a list of ARNs
  alerts_slack_sns_topic_arns = local.cloudwatch_count > 0 ? ["arn:aws:sns:us-east-1:637192944017:alerts-to-slack"] : []
}
