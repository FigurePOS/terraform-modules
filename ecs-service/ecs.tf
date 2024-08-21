
resource "aws_ecs_task_definition" "service" {
  family                   = var.service_name
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.task_cpu
  memory                   = var.task_memory

  container_definitions = jsonencode([
    merge({
      "name" : var.service_name,
      "image" : "${var.ecr_repository_url}:${var.deployment_tag}",
      "cpu" : 0,
      "essential" : true,
      "portMappings" : [
        {
          "containerPort" : var.service_port,
          "hostPort" : var.service_port,
          "protocol" : "tcp"
        }
      ],
      "logConfiguration" : {
        "logDriver" : "awslogs",
        "options" : {
          "awslogs-group" : "/figure/container/${var.service_name}",
          "awslogs-region" : "${var.aws_region}",
          "awslogs-stream-prefix" : "${var.service_name}"
        }
      },
      "entryPoint" : local.entry_point,
      "dockerLabels" : {
        "com.datadoghq.tags.env" : "${var.env}",
        "com.datadoghq.tags.service" : "${var.service_name}",
        "com.datadoghq.tags.version" : "${var.deployment_tag}",
        "org.opencontainers.image.revision" : "${var.git_commit_hash}",
        "org.opencontainers.image.source" : "${var.git_repository}"
      },
      "environment" : setunion([
        {
          "name" : "AWS_REGION",
          "value" : "${var.aws_region}"
        },
        {
          "name" : "DD_DBM_PROPAGATION_MODE",
          "value" : "full"
        },
        {
          "name" : "DD_ENV",
          "value" : "${var.env}"
        },
        {
          "name" : "DD_LOGS_INJECTION",
          "value" : "true"
        },
        {
          "name" : "DD_RUNTIME_METRICS_ENABLED",
          "value" : "true"
        },
        {
          "name" : "DD_SERVICE",
          "value" : "${var.service_name}"
        },
        {
          "name" : "DD_VERSION",
          "value" : "${var.deployment_tag}"
        },
        {
          "name" : "ENVIRONMENT",
          "value" : "${var.env}"
        },
        {
          "name" : "LOGGER_LEVEL",
          "value" : "INFO"
        },
        {
          "name" : "LOGGER_MODE",
          "value" : "json"
        },
        {
          "name" : "NODE_ENV",
          "value" : "${var.env}"
        },
        {
          "name" : "PORT",
          "value" : "${var.service_port}"
        },
        {
          "name" : "SERVICE_NAME",
          "value" : "${var.service_name}"
        }
      ], var.service_envs),
      "secrets" : var.service_secrets,
      "readonlyRootFilesystem" : true,
      "mountPoints" : [],
      "volumesFrom" : [],
      "systemControls" : [],
    }, var.service_custom_definition),
    {
      "name" : "datadog-agent",
      "image" : "public.ecr.aws/datadog/agent:${var.dd_agent_version}",
      "cpu" : 50,
      "memoryReservation" : 256,
      "essential" : true,
      "dockerLabels" : {
        "com.datadoghq.ad.instances" : "[{\"host\": \"%%host%%\", \"port\": ${var.service_port}}]",
        "com.datadoghq.ad.check_names" : "[\"${var.service_name}\"]",
        "com.datadoghq.ad.init_configs" : "[{}]"
      },
      "healthCheck" : {
        "command" : [
          "CMD-SHELL",
          "agent health"
        ],
        "retries" : 5,
        "timeout" : 5,
        "interval" : 10,
        "startPeriod" : 15
      }
      "environment" : [
        {
          "name" : "DD_APM_ENABLED",
          "value" : "true"
        },
        {
          "name" : "DD_APM_NON_LOCAL_TRAFFIC",
          "value" : "true"
        },
        {
          "name" : "DD_DOGSTATSD_NON_LOCAL_TRAFFIC",
          "value" : "true"
        },
        {
          "name" : "DD_LOGS_CONFIG_USE_HTTP",
          "value" : "true"
        },
        {
          "name" : "DD_PROCESS_AGENT_ENABLED",
          "value" : "true"
        },
        {
          "name" : "DD_PROCESS_AGENT_PROCESS_COLLECTION_ENABLED",
          "value" : "true"
        },
        {
          "name" : "DD_REMOTE_CONFIGURATION_ENABLED",
          "value" : "true"
        },
        {
          "name" : "ECS_FARGATE",
          "value" : "true"
        }
      ],
      "secrets" : [
        {
          "name" : "DD_API_KEY",
          "valueFrom" : "secret.datadog.ecs_agent_api_key"
        }
      ],
      ## "readonlyRootFilesystem" : true, # so far not possible for datadog-agent
      "mountPoints" : [],
      "portMappings" : [],
      "volumesFrom" : [],
      "systemControls" : [],
    }
  ])

  tags = {
    "Environment" = var.env
    "Service"     = var.service_name
  }

  skip_destroy = true
}

resource "aws_ecs_service" "service" {
  name            = var.service_name
  cluster         = data.aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.service.arn
  propagate_tags  = "SERVICE"

  enable_execute_command = true

  desired_count                     = var.desired_count
  health_check_grace_period_seconds = var.health_check_grace_period_seconds

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  network_configuration {
    subnets         = data.aws_subnets.private.ids
    security_groups = [data.aws_security_group.cluster.id]
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.service.arn
    container_name   = var.service_name
    container_port   = var.service_port
  }

  capacity_provider_strategy {
    capacity_provider = "FARGATE"
    base              = var.capacity_provider_strategy["ondemand"]["base"]
    weight            = var.capacity_provider_strategy["ondemand"]["weight"]
  }

  capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    base              = var.capacity_provider_strategy["spot"]["base"]
    weight            = var.capacity_provider_strategy["spot"]["weight"]
  }

  tags = {
    "Environment" = var.env
    "Service"     = var.service_name
  }
}
