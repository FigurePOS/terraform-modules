resource "aws_cloudwatch_log_group" "log_group" {
  # checkov:skip=CKV_AWS_158:Log group is not encrypted. TODO
  # checkov:skip=CKV_AWS_338:Ensure CloudWatch log groups retains logs for at least 1 year.
  name              = "/figure/container/${var.service_name}"
  retention_in_days = 3
}
