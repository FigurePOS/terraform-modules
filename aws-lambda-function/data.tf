# Data sources for the Lambda module

data "aws_region" "current" {}

data "aws_s3_bucket" "lambda_deployment" {
  bucket = "fgr-lambda-deployment-${var.env}"
}

data "aws_ssm_parameter" "axiom_api_token" {
  name = "/otel-collector/axiom_token"
}
