# Data sources for the Lambda module

data "aws_region" "current" {}


data "aws_lambda_function" "axiom_log_forwarder" {
  function_name = local.axiom_log_forwarder_function_name
}

data "aws_s3_bucket" "lambda_deployment" {
  bucket = "fgr-lambda-deployment-${var.env}"
}

data "aws_ssm_parameter" "axiom_api_token" {
  name = "/otel-collector/axiom_token"
}
