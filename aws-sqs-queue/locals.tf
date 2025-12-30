locals {
  alarm_name_prefix = "${var.service_name} SQS"
  tags              = merge(var.tags, { Service = var.service_name })

  cloudwatch_alarms_enabled  = var.enable_cloudwatch_alarms ? 1 : 0
  
  # Hardcoded SNS topic ARN for Slack alerts (shared across all accounts)
  # Returns a list for compatibility with alarm_actions which expects a list of ARNs
  alerts_slack_sns_topic_arns = var.enable_cloudwatch_alarms ? ["arn:aws:sns:us-east-1:637192944017:alerts-to-slack"] : []
}
