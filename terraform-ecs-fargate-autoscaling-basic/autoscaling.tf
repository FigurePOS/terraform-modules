
locals {
  resource_id = "service/${var.ecs_cluster_name}/${var.ecs_service_name}"
}

resource "aws_appautoscaling_target" "target" {
  service_namespace = "ecs"
  resource_id = local.resource_id
  scalable_dimension = "ecs:service:DesiredCount"
  min_capacity = var.min_capacity
  max_capacity = var.max_capacity
}

resource "aws_appautoscaling_policy" "up" {
  name = "${var.namespace}_ECS_ScaleUp"
  service_namespace = "ecs"
  resource_id = local.resource_id
  scalable_dimension = "ecs:service:DesiredCount"

  step_scaling_policy_configuration {
    adjustment_type = "ChangeInCapacity"
    cooldown = 60
    metric_aggregation_type = var.metric_aggregation_type

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment = 1
    }
  }

  depends_on = [aws_appautoscaling_target.target]
}

resource "aws_appautoscaling_policy" "down" {
  name = "${var.namespace}_ECS_ScaleDown"
  service_namespace = "ecs"
  resource_id = local.resource_id
  scalable_dimension = "ecs:service:DesiredCount"

  step_scaling_policy_configuration {
    adjustment_type = "ChangeInCapacity"
    cooldown = 60
    metric_aggregation_type = var.metric_aggregation_type

    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment = -1
    }
  }

  depends_on = [aws_appautoscaling_target.target]
}

resource "aws_cloudwatch_metric_alarm" "service_cpu_high" {
  alarm_name = "${var.namespace}_CPUUtilizationHigh"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods = "2"
  metric_name = "CPUUtilization"
  namespace = "AWS/ECS"
  period = "60"
  statistic = "Average"
  threshold = var.high_cpu_threshold

  dimensions = {
    ClusterName = var.ecs_cluster_name
    ServiceName = var.ecs_service_name
  }

  alarm_actions = [aws_appautoscaling_policy.up.arn]
}

resource "aws_cloudwatch_metric_alarm" "service_cpu_low" {
  alarm_name = "${var.namespace}_CPUUtilizationLow"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods = "2"
  metric_name = "CPUUtilization"
  namespace = "AWS/ECS"
  period = "60"
  statistic = "Average"
  threshold = var.low_cpu_threshold

  dimensions = {
    ClusterName = var.ecs_cluster_name
    ServiceName = var.ecs_service_name
  }

  alarm_actions = [aws_appautoscaling_policy.down.arn]
}
