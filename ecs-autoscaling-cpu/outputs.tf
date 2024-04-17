output "autoscaling_policy_up_arn" {
  value = aws_appautoscaling_policy.up.arn
}

output "autoscaling_policy_down_arn" {
  value = aws_appautoscaling_policy.down.arn
}
