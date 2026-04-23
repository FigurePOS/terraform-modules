# CloudWatch alarms for ECS service CPU and memory.
# Warning thresholds notify Slack only; critical thresholds also page on-call via Rootly in production.

locals {
  alarm_name_prefix = "${var.service_name} ECS"
  rootly_enabled    = var.env == "production"

  alerts_slack_sns_topic_arns  = ["arn:aws:sns:us-east-1:637192944017:alerts-to-slack"]
  alerts_rootly_sns_topic_arns = local.rootly_enabled ? data.aws_sns_topic.rootly_oncall[*].arn : []

  utilization_alarm_tags = {
    Service = var.service_name
  }
}

resource "aws_cloudwatch_metric_alarm" "ecs_cpu_warning" {
  alarm_name        = "${local.alarm_name_prefix} - CPU Utilization Warning"
  alarm_description = "ECS service ${var.service_name} average CPU utilization exceeded warning threshold (${var.cpu_utilization_alarm_warning_threshold}%)."

  metric_name = "CPUUtilization"
  namespace   = "AWS/ECS"
  statistic   = "Average"
  period      = var.cloudwatch_period_seconds

  dimensions = {
    ClusterName = data.aws_ecs_cluster.main.cluster_name
    ServiceName = var.service_name
  }

  comparison_operator = "GreaterThanThreshold"
  threshold           = var.cpu_utilization_alarm_warning_threshold
  evaluation_periods  = var.cloudwatch_evaluation_periods
  datapoints_to_alarm = var.cloudwatch_evaluation_periods
  treat_missing_data  = "notBreaching"

  alarm_actions             = local.alerts_slack_sns_topic_arns
  ok_actions                = local.alerts_slack_sns_topic_arns
  insufficient_data_actions = []

  tags = local.utilization_alarm_tags
}

resource "aws_cloudwatch_metric_alarm" "ecs_cpu_critical" {
  alarm_name        = "${local.alarm_name_prefix} - CPU Utilization Critical"
  alarm_description = "ECS service ${var.service_name} average CPU utilization exceeded critical threshold (${var.cpu_utilization_alarm_critical_threshold}%)."

  metric_name = "CPUUtilization"
  namespace   = "AWS/ECS"
  statistic   = "Average"
  period      = var.cloudwatch_period_seconds

  dimensions = {
    ClusterName = data.aws_ecs_cluster.main.cluster_name
    ServiceName = var.service_name
  }

  comparison_operator = "GreaterThanThreshold"
  threshold           = var.cpu_utilization_alarm_critical_threshold
  evaluation_periods  = var.cloudwatch_evaluation_periods
  datapoints_to_alarm = var.cloudwatch_evaluation_periods
  treat_missing_data  = "notBreaching"

  alarm_actions             = concat(local.alerts_slack_sns_topic_arns, local.alerts_rootly_sns_topic_arns)
  ok_actions                = local.alerts_slack_sns_topic_arns
  insufficient_data_actions = []

  tags = local.utilization_alarm_tags
}

resource "aws_cloudwatch_metric_alarm" "ecs_memory_warning" {
  alarm_name        = "${local.alarm_name_prefix} - Memory Utilization Warning"
  alarm_description = "ECS service ${var.service_name} average memory utilization exceeded warning threshold (${var.memory_utilization_alarm_warning_threshold}%)."

  metric_name = "MemoryUtilization"
  namespace   = "AWS/ECS"
  statistic   = "Average"
  period      = var.cloudwatch_period_seconds

  dimensions = {
    ClusterName = data.aws_ecs_cluster.main.cluster_name
    ServiceName = var.service_name
  }

  comparison_operator = "GreaterThanThreshold"
  threshold           = var.memory_utilization_alarm_warning_threshold
  evaluation_periods  = var.cloudwatch_evaluation_periods
  datapoints_to_alarm = var.cloudwatch_evaluation_periods
  treat_missing_data  = "notBreaching"

  alarm_actions             = local.alerts_slack_sns_topic_arns
  ok_actions                = local.alerts_slack_sns_topic_arns
  insufficient_data_actions = []

  tags = local.utilization_alarm_tags
}

resource "aws_cloudwatch_metric_alarm" "ecs_memory_critical" {
  alarm_name        = "${local.alarm_name_prefix} - Memory Utilization Critical"
  alarm_description = "ECS service ${var.service_name} average memory utilization exceeded critical threshold (${var.memory_utilization_alarm_critical_threshold}%)."

  metric_name = "MemoryUtilization"
  namespace   = "AWS/ECS"
  statistic   = "Average"
  period      = var.cloudwatch_period_seconds

  dimensions = {
    ClusterName = data.aws_ecs_cluster.main.cluster_name
    ServiceName = var.service_name
  }

  comparison_operator = "GreaterThanThreshold"
  threshold           = var.memory_utilization_alarm_critical_threshold
  evaluation_periods  = var.cloudwatch_evaluation_periods
  datapoints_to_alarm = var.cloudwatch_evaluation_periods
  treat_missing_data  = "notBreaching"

  alarm_actions             = concat(local.alerts_slack_sns_topic_arns, local.alerts_rootly_sns_topic_arns)
  ok_actions                = local.alerts_slack_sns_topic_arns
  insufficient_data_actions = []

  tags = local.utilization_alarm_tags
}
