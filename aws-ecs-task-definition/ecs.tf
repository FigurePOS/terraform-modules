locals {
  common_tags = {
    "Service" = var.service_name
  }

  default_service_envs = [
    {
      name  = "AWS_ACCOUNT_ID",
      value = var.aws_account_id
    },
    {
      name  = "AWS_REGION",
      value = var.aws_region
    },
    {
      name  = "ENVIRONMENT",
      value = var.env
    },
    {
      name  = "LOGGER_LEVEL",
      value = "INFO"
    },
    {
      name  = "LOGGER_MODE",
      value = "json"
    },
    {
      name  = "NODE_ENV",
      value = var.env
    },
    {
      name  = "OTEL_EXPORTER_OTLP_ENDPOINT",
      value = "http://otel-collector:4318"
    },
    {
      name  = "OTEL_RESOURCE_ATTRIBUTES",
      value = "environment=${var.env},deployment.environment=${var.env}"
    },
    {
      name  = "OTEL_SERVICE_NAME",
      value = "${var.service_name}"
    },
    {
      name  = "OTEL_SERVICE_VERSION",
      value = "${var.deployment_tag}"
    },
    {
      name  = "PORT",
      value = var.service_port
    },
    {
      name  = "SERVICE_NAME",
      value = var.service_name
    }
  ]

  # Only set OTEL_TRACES_SAMPLER if rate limiting is not configured
  # Rate limiting takes precedence and will ignore OTEL_TRACES_SAMPLER
  otel_traces_sampler_envs_map = var.otel_traces_rate_limit != null || var.otel_traces_sampler_arg == "" ? {} : {
    OTEL_TRACES_SAMPLER     = var.otel_traces_sampler
    OTEL_TRACES_SAMPLER_ARG = var.otel_traces_sampler_arg
  }

  # Rate limiting sampler configuration
  otel_rate_limit_envs_map = var.otel_traces_rate_limit != null ? {
    OTEL_TRACES_RATE_LIMIT = tostring(var.otel_traces_rate_limit)
  } : {}

  default_service_secrets = []

  # Convert default environment to a map for easier merging
  default_service_envs_map = { for item in local.default_service_envs : item.name => item.value }

  # Convert service_envs to a map (if it's in the expected format)
  service_envs_map = { for item in var.service_envs : item.name => item.value if can(item.name) && can(item.value) }

  service_node_options_override         = lookup(local.service_envs_map, "NODE_OPTIONS", "")
  service_envs_map_without_node_options = { for name, value in local.service_envs_map : name => value if name != "NODE_OPTIONS" }

  # Node runtime flags and OTEL preload run via NODE_OPTIONS so they apply before the app entry script loads.
  node_runtime_options = var.node_script != "" ? "--enable-source-maps --no-network-family-autoselection --dns-result-order=ipv4first" : ""
  otel_preload_option  = var.node_script != "" ? "--require @figurepos/lib-observability/ecs/register" : ""
  default_node_options = trimspace("${local.node_runtime_options} ${local.otel_preload_option}")
  node_options         = local.default_node_options != "" ? trimspace("${local.default_node_options} ${local.service_node_options_override}") : local.service_node_options_override

  # Merge the maps, with service_env_map taking precedence
  merged_service_envs_map = merge(
    local.default_service_envs_map,
    local.otel_traces_sampler_envs_map,
    local.otel_rate_limit_envs_map,
    local.service_envs_map_without_node_options,
    local.node_options != "" ? { NODE_OPTIONS = local.node_options } : {},
  )

  # Convert back to the list format required by the module
  service_environment = [for name, value in local.merged_service_envs_map : { name = name, value = value }]

  # Convert default secrets to a map for easier merging
  default_service_secrets_map = { for item in local.default_service_secrets : item.name => item.valueFrom if can(item.name) && can(item.valueFrom) }

  # Convert service_secrets to a map (if it's in the expected format)
  service_secrets_map = { for item in var.service_secrets : item.name => item.valueFrom if can(item.name) && can(item.valueFrom) }

  # Merge the maps, with service_secrets_map taking precedence
  merged_service_secrets_map = merge(local.default_service_secrets_map, local.service_secrets_map)

  # Convert back to the list format required by the module
  service_secrets = [for name, valueFrom in local.merged_service_secrets_map : { name = name, valueFrom = valueFrom }]
}

module "app_container_definition" {
  # checkov:skip=CKV_TF_1: "Ensure Terraform module sources use a commit hash"
  source  = "cloudposse/ecs-container-definition/aws"
  version = "0.61.2"

  container_name  = var.service_name
  container_image = "${var.aws_account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/${var.ecr_repository_uri}:${var.deployment_tag}"
  essential       = true
  entrypoint      = local.entry_point

  environment = local.service_environment

  secrets = local.service_secrets

  port_mappings = [
    {
      name          = "http"
      containerPort = var.service_port
      hostPort      = var.service_port
      protocol      = "tcp"
    }
  ]

  docker_labels = {
    "org.opencontainers.image.revision" = var.git_commit_hash,
    "org.opencontainers.image.source"   = var.git_repository,
  }

  log_configuration = {
    logDriver = "awslogs",
    options = {
      awslogs-group         = "/figure/container/${var.service_name}",
      awslogs-region        = var.aws_region,
      awslogs-stream-prefix = var.service_name
    }
  }

  readonly_root_filesystem = var.readonly_root_filesystem

  ulimits = var.ulimits

  mount_points    = []
  system_controls = []
  volumes_from    = []
}

resource "aws_ecs_task_definition" "ecs_task_definition" {
  family                   = var.service_name
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.task_cpu
  memory                   = var.task_memory

  container_definitions = jsonencode([
    module.app_container_definition.json_map_object,
  ])

  tags = local.common_tags

  skip_destroy = true
}
