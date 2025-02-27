locals {
  common_tags = {
    "Environment" = var.env
    "Service"     = var.service_name
  }

  default_service_envs = [
    {
      name  = "AWS_REGION",
      value = var.aws_region
    },
    {
      name  = "DD_DBM_PROPAGATION_MODE",
      value = "full"
    },
    {
      name  = "DD_ENV",
      value = "${var.env}"
    },
    {
      name  = "DD_LOGS_INJECTION",
      value = "true"
    },
    {
      name  = "DD_RUNTIME_METRICS_ENABLED",
      value = "true"
    },
    {
      name  = "DD_SERVICE",
      value = "${var.service_name}"
    },
    {
      name  = "DD_VERSION",
      value = "${var.deployment_tag}"
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
      name  = "OTEL_EXPORTER_OTLP_COMPRESSION",
      value = "gzip"
    },
    {
      name  = "OTEL_EXPORTER_OTLP_ENDPOINT",
      value = "http://localhost:4317"
    },
    {
      name  = "OTEL_EXPORTER_OTLP_PROTOCOL",
      value = "grpc"
    },
    {
      name  = "OTEL_EXPORTER_OTLP_TRACES_PROTOCOL",
      value = "grpc"
    },
    {
      name  = "OTEL_INSTRUMENTATION_HTTP_CAPTURE_HEADERS_SERVER_REQUEST",
      value = "x-request-id,x-correlation-id"
    },
    {
      name  = "OTEL_INSTRUMENTATION_HTTP_CAPTURE_HEADERS_SERVER_RESPONSE",
      value = "content-length,content-type"
    },
    {
      name  = "OTEL_NODE_RESOURCE_DETECTORS",
      value = "env,host,os"
    },
    {
      name  = "OTEL_PROPAGATORS",
      value = "tracecontext,baggage"
    },
    {
      name  = "OTEL_SDK_DISABLED",
      value = "false"
    },
    {
      name  = "OTEL_TRACES_EXPORTER",
      value = "otlp"
    },
    {
      name  = "PORT",
      value = var.service_port
    },
    {
      name  = "SERVICE_NAME",
      value = var.service_name
    },
    {
      name  = "SERVICE_VERSION",
      value = "${var.deployment_tag}"
    }
  ]

  default_service_secrets = [
    {
      name      = "OTEL_EXPORTER_OTLP_HEADERS",
      valueFrom = "/ecs/signoz/otel-exporter-otlp-headers"
    },
  ]
  

  # Convert default environment to a map for easier merging
  default_service_envs_map = { for item in local.default_service_envs : item.name => item.value }

  # Convert service_envs to a map (if it's in the expected format)
  service_envs_map = { for item in var.service_envs : item.name => item.value if can(item.name) && can(item.value) }

  # Merge the maps, with service_env_map taking precedence
  merged_service_envs_map = merge(local.default_service_envs_map, local.service_envs_map)

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
  version = "0.61.1"

  container_name  = var.service_name
  container_image = "${var.aws_account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/${var.ecr_repository_uri}:${var.deployment_tag}"
  essential       = true
  entrypoint      = local.entry_point

  environment = local.service_environment

  secrets = local.service_secrets

  port_mappings = [
    {
      containerPort = var.service_port
      hostPort      = var.service_port
      protocol      = "tcp"
    }
  ]

  docker_labels = {
    "com.datadoghq.tags.env"            = "${var.env}",
    "com.datadoghq.tags.service"        = "${var.service_name}",
    "com.datadoghq.tags.version"        = "${var.deployment_tag}",
    "org.opencontainers.image.revision" = var.git_commit_hash,
    "org.opencontainers.image.source"   = var.git_repository
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
}

module "datadog_agent_definition" {
  # checkov:skip=CKV_TF_1: "Ensure Terraform module sources use a commit hash"
  source  = "cloudposse/ecs-container-definition/aws"
  version = "0.61.1"

  container_name  = "datadog-agent"
  container_image = "${var.aws_account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/ecr-public/datadog/agent:${var.dd_agent_version}"
  essential       = true

  container_cpu                = 50
  container_memory_reservation = 256

  environment = [
    {
      name  = "DD_APM_ENABLED",
      value = "true"
    },
    {
      name  = "DD_APM_NON_LOCAL_TRAFFIC",
      value = "true"
    },
    {
      name  = "DD_DOGSTATSD_NON_LOCAL_TRAFFIC",
      value = "true"
    },
    {
      name  = "DD_LOGS_CONFIG_USE_HTTP",
      value = "true"
    },
    {
      name  = "DD_PROCESS_AGENT_ENABLED",
      value = "true"
    },
    {
      name  = "DD_PROCESS_AGENT_PROCESS_COLLECTION_ENABLED",
      value = "true"
    },
    {
      name  = "DD_REMOTE_CONFIGURATION_ENABLED",
      value = "true"
    },
    {
      name  = "ECS_FARGATE",
      value = "true"
    }
  ]

  secrets = [
    {
      name      = "DD_API_KEY",
      valueFrom = "secret.datadog.ecs_agent_api_key"
    }
  ]

  docker_labels = {
    "com.datadoghq.ad.instances"    = "[{\"host\": \"%%host%%\", \"port\": ${var.service_port}}]",
    "com.datadoghq.ad.check_names"  = "[\"${var.service_name}\"]",
    "com.datadoghq.ad.init_configs" = "[{}]"
  }

  healthcheck = {
    command = [
      "CMD-SHELL",
      "agent health"
    ],
    interval    = 10,
    timeout     = 5,
    retries     = 5,
    startPeriod = 15
  }

  readonly_root_filesystem = false
}

module "signoz_collector_definition" {
  # checkov:skip=CKV_AWS_336:This is needed for the ECS service to communicate with Datadog.
  source  = "cloudposse/ecs-container-definition/aws"
  version = "0.61.1"

  container_name  = "signoz-collector"
  container_image = "signoz/signoz-otel-collector:0.111.29"
  essential       = true

  container_cpu                = 50
  container_memory_reservation = 256

  command = [
    "--config=env:SIGNOZ_CONFIG_CONTENT"
  ]

  secrets = [
    {
      name      = "SIGNOZ_CONFIG_CONTENT",
      valueFrom = "/ecs/signoz/otelcol-config.yaml"
    }
  ]

  port_mappings = [
    {
      protocol      = "tcp",
      containerPort = 4317,
      hostPort      = 4317
    },
    {
      protocol      = "tcp",
      containerPort = 4318,
      hostPort      = 4318
    },
    {
      protocol      = "tcp",
      containerPort = 8006,
      hostPort      = 8006
    }
  ]

  healthcheck = {
    command = [
      "CMD-SHELL",
      "wget -qO- http://localhost:13133/ || exit 1"
    ],
    interval     = 5,
    timeout      = 6,
    retries      = 5,
    start_period = 1
  }

  log_configuration = {
    logDriver = "awslogs",
    options = {
      awslogs-group         = "/figure/container/${var.service_name}",
      awslogs-region        = var.aws_region,
      awslogs-stream-prefix = "signoz",
    }
  }
}

resource "aws_ecs_task_definition" "ecs_task_definition" {
  # checkov:skip=CKV_AWS_336:This is needed for the ECS service to communicate with Datadog.
  family                   = var.service_name
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.task_cpu
  memory                   = var.task_memory

  container_definitions = jsonencode([
    module.app_container_definition.json_map_object,
    module.datadog_agent_definition.json_map_object,
    module.signoz_collector_definition.json_map_object,
  ])

  tags = local.common_tags

  skip_destroy = true
}
