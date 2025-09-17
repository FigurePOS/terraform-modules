data "aws_kms_key" "sqs_encryption_key" {
  key_id = "alias/sqs-encryption-key"
}

data "aws_sns_topic" "chatbot_slack" {
  name = "cloudwatch-sqs-alarms-to-slack"
}

data "aws_sns_topic" "rootly_oncall" {
  name = "alerts-to-rootly"
}
