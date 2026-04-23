data "aws_kms_key" "sqs_encryption_key" {
  key_id = "alias/sqs-encryption-key"
}

data "aws_sns_topic" "rootly_oncall" {
  count = local.rootly_enabled ? 1 : 0

  name = "alerts-to-rootly"
}
