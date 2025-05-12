# Data sources for the Lambda module

data "aws_region" "current" {}

data "aws_s3_bucket" "lambda_deployment" {
  bucket = "fgr-lambda-deployment-${var.env}"
} 

data "aws_ssm_parameter" "datadog_api_key" {
  name = "/lambda/datadog/api_key"
}
