# Data sources for the Lambda module

data "aws_region" "current" {}

data "aws_s3_bucket" "lambda_deployment" {
  bucket = "fgr-lambda-deployment-${var.env}"
} 

data "aws_secretsmanager_secret" "datadog_api_key" {
  name = "datadog-lambda-api-key"
}
