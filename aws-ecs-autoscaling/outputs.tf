output "cpu_scaling_policy_arn" {
  description = "The ARN of the cpu target tracking scaling policy"
  value       = aws_appautoscaling_policy.cpu_target_tracking.arn
}

output "memory_scaling_policy_arn" {
  description = "The ARN of the memory target tracking scaling policy"
  value       = aws_appautoscaling_policy.memory_target_tracking[0].arn
}
