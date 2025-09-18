data "aws_kms_key" "sqs_encryption_key" {
  key_id = "alias/sqs-encryption-key"
}

data "aws_sns_topic" "chatbot_slack" {
  count = local.cloudwatch_count
  name  = "cloudwatch-sqs-alarms-to-slack"
}

data "aws_sns_topic" "rootly_oncall" {
  count = local.cloudwatch_count
  name  = "alerts-to-rootly"
}
