output "dlq_arn" {
  value = aws_sqs_queue.dlq.arn
}

output "dlq_name" {
  value = aws_sqs_queue.dlq.name
}

output "dlq_url" {
  value = aws_sqs_queue.dlq.url
}

output "queue_arn" {
  value = aws_sqs_queue.queue.arn
}

output "queue_name" {
  value = aws_sqs_queue.queue.name
}

output "queue_url" {
  value = aws_sqs_queue.queue.url
}

output "datadog_dlq_messages_monitor_id" {
  description = "Datadog monitor ID for DLQ message count re-notifications."
  value       = datadog_monitor.dlq_messages_count.id
}
