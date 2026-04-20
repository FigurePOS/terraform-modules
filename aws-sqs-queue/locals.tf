locals {
  alarm_name_prefix = "${var.service_name} SQS"
  tags              = merge(var.tags, { Service = var.service_name })

  cloudwatch_alarms_enabled = var.env == "production" ? 1 : 0

  alerts_slack_sns_topic_arns  = local.cloudwatch_alarms_enabled == 1 ? ["arn:aws:sns:us-east-1:637192944017:alerts-to-slack"] : []
  alerts_rootly_sns_topic_arns = data.aws_sns_topic.rootly_oncall[*].arn
}
