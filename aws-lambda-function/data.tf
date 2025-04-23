# Data sources for the Lambda module

data "aws_region" "current" {}

data "aws_s3_bucket" "lambda_deployment" {
  bucket = "fgr-lambda-deployment-${var.env}"
} 

data "aws_ssm_parameter" "datadog_ecs_agent_api_key" {
  name = "/secret.datadog.ecs_agent_api_key"
}
