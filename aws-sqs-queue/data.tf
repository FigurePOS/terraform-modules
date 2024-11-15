data "aws_kms_key" "sqs_encryption_key" {
  key_id = "alias/sqs-encryption-key"
}
