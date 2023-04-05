
output "monitor_number_of_messages" {
  value = datadog_monitor.sqs_number_of_messages_monitor
}

output "monitor_number_of_messages_in_dead_letter" {
  value = datadog_monitor.sqs_number_of_messages_dead_letter_monitor
}
