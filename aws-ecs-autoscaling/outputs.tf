output "scaling_policy_arn" {
  description = "The ARN of the target tracking scaling policy"
  value       = aws_appautoscaling_policy.target_tracking.arn
}
