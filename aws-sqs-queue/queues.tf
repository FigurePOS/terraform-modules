resource "aws_sqs_queue" "normal" {
  name                      = "${var.service_name}_Queue${var.fifo_queue ? ".fifo" : ""}"
  message_retention_seconds = var.message_retention_seconds
  fifo_queue                = var.fifo_queue

  deduplication_scope   = var.deduplication_scope
  fifo_throughput_limit = var.fifo_throughput_limit

  kms_master_key_id                 = var.kms_master_key_id
  kms_data_key_reuse_period_seconds = 300

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.ddl.arn
    maxReceiveCount     = var.redrive_policy_count
  })
}

resource "aws_sqs_queue" "ddl" {
  name                      = "${var.service_name}_DeadLetterQueue${var.fifo_queue ? ".fifo" : ""}"
  message_retention_seconds = var.message_retention_seconds_ddl
  fifo_queue                = var.fifo_queue

  kms_master_key_id                 = var.kms_master_key_id
  kms_data_key_reuse_period_seconds = 300
}
