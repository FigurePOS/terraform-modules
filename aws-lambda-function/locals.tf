locals {
  # Calculate a hash of the source code for determining when to rebuild
  source_files_hash = sha256(join(",", [
    filesha256("${var.source_dir}/package.json"),
    filesha256("${var.source_dir}/package-lock.json"),
    filesha256("${var.source_dir}/tsconfig.json"),
    sha256(join("", [for f in fileset("${var.source_dir}", "**/*.ts") : filesha256("${var.source_dir}/${f}")]))
  ]))
  lambda_name       = basename(var.source_dir) # Extract the lambda name from the source directory path
  build_output_dir  = abspath(pathexpand(var.output_dir))
  zip_path          = "${local.build_output_dir}/${local.lambda_name}.zip"
  build_script_path = "${path.module}/build.sh"

  # Environment variables for Datadog integration
  datadog_env_vars = {
    DD_API_KEY                = data.aws_ssm_parameter.datadog_ecs_agent_api_key.value
    DD_CAPTURE_LAMBDA_PAYLOAD = true
    DD_ENV                    = var.env
    DD_SERVICE                = var.service_name
    DD_SERVICE_MAPPING        = var.dd_service_mapping
    DD_TAGS                   = "service:${var.service_name},git.repository_url:${var.git_repository_url}"
  }

  environment_variables = merge(local.datadog_env_vars, var.environment_variables)
  datadog_layer_arn     = "arn:aws:lambda:${data.aws_region.current.name}:464622532012:layer:Datadog-Node22-x:124"
  scheduling_enabled    = var.schedule_expression != ""
}
