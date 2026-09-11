locals {
  alarm_name_prefix = "${var.service_name} SQS ${var.queue_name}"
  tags              = merge(var.tags, { Service = var.service_name })

  rootly_enabled = var.env == "production"

  alerts_slack_sns_topic_arns  = ["arn:aws:sns:us-east-1:637192944017:alerts-to-slack"]
  alerts_rootly_sns_topic_arns = local.rootly_enabled ? data.aws_sns_topic.rootly_oncall[*].arn : []

  grafana_cloudwatch_datasource_uid = "aws-cloudwatch-${var.env}"
  grafana_dlq_group_name            = "${var.service_name}-sqs-dlq-${var.queue_name}-${var.env}"
  grafana_eval_interval_seconds     = 300
  grafana_lookback_seconds          = 600
}
