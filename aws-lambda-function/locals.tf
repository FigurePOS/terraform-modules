locals {
  # Calculate a hash of the source code for determining when to rebuild
  # Only includes files that actually affect the build output
  source_files = {
    package_json      = fileexists("${var.source_dir}/package.json") ? file("${var.source_dir}/package.json") : ""
    package_lock_json = fileexists("${var.source_dir}/package-lock.json") ? file("${var.source_dir}/package-lock.json") : ""
    tsconfig          = fileexists("${var.source_dir}/tsconfig.json") ? file("${var.source_dir}/tsconfig.json") : ""
    esbuild_config    = fileexists("${var.source_dir}/esbuild.config.mjs") ? file("${var.source_dir}/esbuild.config.mjs") : ""
    # Sort source files for consistent hash across machines
    source_files = join("", [for f in sort(fileset("${var.source_dir}", "src/**/*.ts")) : file("${var.source_dir}/${f}")])
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

  # Environment variables for OpenTelemetry integration
  # Send OTLP to Datadog extension (v53+) which forwards to Datadog
  otel_env_vars = {
    NODE_OPTIONS                = "--enable-source-maps"
    OTEL_EXPORTER_OTLP_ENDPOINT = "http://localhost:4318"
    OTEL_RESOURCE_ATTRIBUTES    = "service.name=${var.service_name},service.version=${var.git_commit_hash != "" ? var.git_commit_hash : "unknown"},deployment.environment=${var.env}${var.git_repository_url != "" ? ",git.repository_url=${var.git_repository_url}" : ""}"
    OTEL_SERVICE_NAME           = var.service_name
    OTEL_SERVICE_VERSION        = var.git_commit_hash != "" ? var.git_commit_hash : "unknown"
  }

  datadog_extension_env_vars = {
    DD_API_KEY_SECRET_ARN                           = data.aws_secretsmanager_secret.datadog_api_key.arn
    DD_ENV                                          = var.env
    DD_OTLP_CONFIG_RECEIVER_PROTOCOLS_HTTP_ENDPOINT = "localhost:4318"
    DD_SERVICE                                      = var.service_name

  }

  environment_variables = merge(local.otel_env_vars, local.datadog_extension_env_vars, var.environment_variables)

  datadog_extension_layer_arn = "arn:aws:lambda:${data.aws_region.current.region}:464622532012:layer:Datadog-Extension:${var.datadog_extension_layer_version}"

  scheduling_enabled = var.schedule_expression != ""

  # CloudWatch alarms configuration
  cloudwatch_count  = var.enable_cloudwatch_alarms ? 1 : 0
  alarm_name_prefix = "${var.service_name} Lambda"
  
  # Hardcoded SNS topic ARN for Slack alerts (shared across all accounts)
  # Returns a list for compatibility with alarm_actions which expects a list of ARNs
  alerts_slack_sns_topic_arns = local.cloudwatch_count > 0 ? ["arn:aws:sns:us-east-1:637192944017:alerts-to-slack"] : []
}
