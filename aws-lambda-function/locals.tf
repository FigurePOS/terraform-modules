locals {
  # Calculate a hash of the source code for determining when to rebuild
  source_files_hash = sha256(join(",", compact([
    filesha256("${var.source_dir}/package.json"),
    filesha256("${var.source_dir}/package-lock.json"),
    fileexists("${var.source_dir}/tsconfig.json") ? filesha256("${var.source_dir}/tsconfig.json") : "",
    fileexists("${var.source_dir}/esbuild.config.mjs") ? filesha256("${var.source_dir}/esbuild.config.mjs") : "",
    sha256(join("", [for f in fileset("${var.source_dir}", "**/*.ts") : filesha256("${var.source_dir}/${f}")]))
  ])))
  lambda_name       = basename(var.source_dir) # Extract the lambda name from the source directory path
  build_output_dir  = abspath(pathexpand(var.output_dir))
  zip_path          = "${local.build_output_dir}/${local.lambda_name}.zip"
  build_script_path = "${path.module}/build.sh"

  # Environment variables for Datadog integration
  datadog_env_vars = {
    DD_API_KEY_SECRET_ARN        = data.aws_secretsmanager_secret.datadog_api_key.arn
    DD_CAPTURE_LAMBDA_PAYLOAD    = true
    DD_ENV                       = var.env
    DD_LAMBDA_HANDLER            = var.handler
    DD_PROFILING_ENABLED         = false
    DD_SERVERLESS_APPSEC_ENABLED = false
    DD_SERVICE                   = var.service_name
    DD_SERVICE_MAPPING           = var.dd_service_mapping
    DD_TAGS                      = "service:${var.service_name},git.repository_url:${var.git_repository_url}"
    DD_TRACE_ENABLED             = true
    DD_TRACE_OTEL_ENABLED        = false
    NODE_OPTIONS                 = "--enable-source-maps"
  }

  environment_variables = merge(local.datadog_env_vars, var.environment_variables)

  datadog_layer_arn           = "arn:aws:lambda:${data.aws_region.current.name}:464622532012:layer:Datadog-Node22-x:${var.datadog_layer_version}"
  datadog_extension_layer_arn = "arn:aws:lambda:${data.aws_region.current.name}:464622532012:layer:Datadog-Extension:${var.datadog_extension_layer_version}"

  scheduling_enabled = var.schedule_expression != ""
}
