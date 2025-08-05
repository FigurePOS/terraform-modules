# Build the Lambda package
resource "null_resource" "build_lambda" {
  # Only rebuild when source code or build script changes
  triggers = {
    source_code_hash = local.source_files_hash
    script_hash      = filesha256(local.build_script_path)
  }

  provisioner "local-exec" {
    command = "sh ${local.build_script_path} ${local.lambda_name} ${var.source_dir}"
  }
}

# Upload the Lambda package to S3
resource "aws_s3_object" "lambda_package" {
  bucket = data.aws_s3_bucket.lambda_deployment.bucket
  key    = "${var.function_name}/${local.source_files_hash}.zip"

  source      = local.zip_path
  source_hash = local.source_files_hash

  depends_on = [null_resource.build_lambda]
}

# CloudWatch Log Group for Lambda
resource "aws_cloudwatch_log_group" "lambda" {
  //checkov:skip=CKV_AWS_338: "Ensure CloudWatch log groups retains logs for at least 1 year" - We retain logs using Datadog → S3 integration.
  name              = "/aws/lambda/${var.function_name}"
  retention_in_days = 7
  tags              = var.tags
}

# Lambda Function
resource "aws_lambda_function" "this" {
  //checkov:skip=CKV_AWS_50: "X-Ray tracing is enabled for Lambda"
  //checkov:skip=CKV_AWS_115: "Ensure that AWS Lambda function is configured for function-level concurrent execution limit"
  //checkov:skip=CKV_AWS_116: "Ensure that AWS Lambda function is configured for a Dead Letter Queue(DLQ)"
  //checkov:skip=CKV_AWS_173: "Check encryption settings for Lambda environmental variable"
  //checkov:skip=CKV_AWS_272: "Ensure AWS Lambda function is configured to validate code-signing"
  function_name = var.function_name
  description   = var.description
  handler       = "/opt/nodejs/node_modules/datadog-lambda-js/handler.handler"
  runtime       = var.runtime
  timeout       = var.timeout
  memory_size   = var.memory_size
  role          = aws_iam_role.lambda_role.arn

  s3_bucket        = data.aws_s3_bucket.lambda_deployment.bucket
  s3_key           = aws_s3_object.lambda_package.key
  source_code_hash = base64encode(local.source_files_hash)

  # Optional concurrency configuration
  reserved_concurrent_executions = var.reserved_concurrent_executions

  publish = true
  layers = concat(
    var.datadog_layer_version != 0 ? [local.datadog_layer_arn] : [],
    var.datadog_extension_layer_version != 0 ? [local.datadog_extension_layer_arn] : [],
    var.layers
  )

  depends_on = [
    aws_cloudwatch_log_group.lambda,
    aws_s3_object.lambda_package
  ]

  # Ensure proper handling of replacements
  lifecycle {
    create_before_destroy = true
  }

  environment {
    variables = local.environment_variables
  }

  dynamic "vpc_config" {
    for_each = length(var.vpc_subnet_ids) > 0 ? [1] : []
    content {
      subnet_ids         = var.vpc_subnet_ids
      security_group_ids = var.vpc_security_group_ids
    }
  }

  tags = var.tags
}
