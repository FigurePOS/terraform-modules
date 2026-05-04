locals {
  lambda_log_group_prefix = {
    application = "/figure/lambda"
    platform    = "/platform/lambda"
  }[var.category]

  axiom_traces_dataset = {
    application = "node-js-traces"
    platform    = "platform-traces"
  }[var.category]
  axiom_traces_dataset_env_suffix = {
    development = "dev"
    production  = "prod"
  }
  axiom_traces_dataset_name = "${local.axiom_traces_dataset}-${lookup(local.axiom_traces_dataset_env_suffix, var.env, var.env)}"

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

  # OpenTelemetry: OTLP/HTTP to Axiom (https://axiom.co/docs/send-data/opentelemetry)
  default_node_options = "--enable-source-maps --require @figurepos/lib-lambda-telemetry/register"
  node_options         = trimspace("${local.default_node_options} ${lookup(var.environment_variables, "NODE_OPTIONS", "")}")

  otel_env_vars = {
    OTEL_EXPORTER_OTLP_COMPRESSION = "gzip"
    OTEL_EXPORTER_OTLP_ENDPOINT    = var.otlp_http_endpoint
    OTEL_EXPORTER_OTLP_HEADERS     = "authorization=Bearer%20${data.aws_ssm_parameter.axiom_api_token.value},x-axiom-dataset=${local.axiom_traces_dataset_name}"
    OTEL_EXPORTER_OTLP_PROTOCOL    = "http/protobuf"
    OTEL_RESOURCE_ATTRIBUTES       = "service.name=${var.service_name},service.version=${var.git_commit_hash != "" ? var.git_commit_hash : "unknown"},deployment.environment=${var.env},lambda.name=${var.function_name},cloud.provider=aws,cloud.platform=aws_lambda"
    OTEL_SERVICE_NAME              = var.service_name
    OTEL_SERVICE_VERSION           = var.git_commit_hash != "" ? var.git_commit_hash : "unknown"
  }

  environment_variables = merge(local.otel_env_vars, var.environment_variables, {
    NODE_OPTIONS = local.node_options
  })

  scheduling_enabled = var.schedule_expression != ""

  # CloudWatch alarms configuration
  cloudwatch_alarms_enabled = var.enable_cloudwatch_alarms ? 1 : 0
  alarm_name_prefix         = "${var.service_name} Lambda"
  alarm_tags                = merge(var.tags, { Service = var.service_name })

  # Hardcoded SNS topic ARN for Slack alerts (shared across all accounts)
  # Returns a list for compatibility with alarm_actions which expects a list of ARNs
  alerts_slack_sns_topic_arns = var.enable_cloudwatch_alarms ? ["arn:aws:sns:us-east-1:637192944017:alerts-to-slack"] : []
}
