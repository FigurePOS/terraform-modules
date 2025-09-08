locals {
  # Calculate a hash of the source code for determining when to rebuild
  # Only includes files that actually affect the build output
  source_files = {
    package_json      = fileexists("${var.source_dir}/package.json") ? file("${var.source_dir}/package.json") : ""
    package_lock_json = fileexists("${var.source_dir}/package-lock.json") ? file("${var.source_dir}/package-lock.json") : ""
    tsconfig          = fileexists("${var.source_dir}/tsconfig.json") ? file("${var.source_dir}/tsconfig.json") : ""
    esbuild_config    = fileexists("${var.source_dir}/esbuild.config.mjs") ? file("${var.source_dir}/esbuild.config.mjs") : ""
    # Sort source files for consistent hash across machines
    source_files      = join("", [for f in sort(fileset("${var.source_dir}", "src/**/*.ts")) : file("${var.source_dir}/${f}")])
  }
  
  # Create a stable hash that's consistent across machines and file systems
  source_files_hash = sha256(jsonencode({
    files = local.source_files
    # Include function name to ensure different functions have different hashes
    function_name = var.function_name
  }))
  
  # Build directories - use module-relative paths for consistency across machines
  build_dir        = "${path.module}/.build/${var.function_name}"
  build_output_dir = "${local.build_dir}/dist"
  zip_output_path  = "${path.module}/.build/${var.function_name}.zip"

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

  datadog_layer_arn           = "arn:aws:lambda:${data.aws_region.current.region}:464622532012:layer:Datadog-Node22-x:${var.datadog_layer_version}"
  datadog_extension_layer_arn = "arn:aws:lambda:${data.aws_region.current.region}:464622532012:layer:Datadog-Extension:${var.datadog_extension_layer_version}"

  scheduling_enabled = var.schedule_expression != ""
}
