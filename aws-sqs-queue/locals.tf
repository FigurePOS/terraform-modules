locals {
  alarm_name_prefix = "${var.service_name} SQS"
  tags              = merge(var.tags, { Service = var.service_name })

  rootly_enabled = var.env == "production"

  alerts_slack_sns_topic_arns  = ["arn:aws:sns:us-east-1:637192944017:alerts-to-slack"]
  alerts_rootly_sns_topic_arns = local.rootly_enabled ? data.aws_sns_topic.rootly_oncall[*].arn : []
}
