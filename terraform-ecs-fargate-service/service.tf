
resource "aws_ecs_task_definition" "service" {
  family                   = var.service_name
  execution_role_arn       = var.task_execution_role_arn
  task_role_arn            = var.task_role_arn
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
      "entryPoint" : [
        "sh",
        "-c",
        "exec node --enable-source-maps ${var.entry_point}"
      ],
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
          "name" : "PATH_PREFIX",
          "value" : "/${var.service_name}"
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
    }, var.service_custom_definition),
    {
      "name" : "datadog-agent",
      "image" : "public.ecr.aws/datadog/agent:latest",
      "cpu" : 10,
      "memoryReservation" : 256,
      "essential" : true,
      "dockerLabels" : {
        "com.datadoghq.ad.instances" : "[{\"host\": \"%%host%%\", \"port\": ${var.service_port}}]",
        "com.datadoghq.ad.check_names" : "[\"${var.service_name}\"]",
        "com.datadoghq.ad.init_configs" : "[{}]"
      },
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
    }
  ])
}

resource "aws_ecs_service" "service" {
  name            = var.service_name
  cluster         = var.ecs_cluster_id
  launch_type     = "FARGATE"
  task_definition = aws_ecs_task_definition.service.arn
  propagate_tags  = "SERVICE"

  desired_count                     = var.desired_count
  health_check_grace_period_seconds = 30

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  network_configuration {
    subnets         = var.subnet_ids
    security_groups = var.security_group_ids
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.service.arn
    container_name   = var.service_name
    container_port   = var.service_port
  }
}

resource "aws_alb_target_group" "service" {
  name                 = substr(var.service_name, 0, 32)
  port                 = 80
  protocol             = "HTTP"
  vpc_id               = var.vpc_id
  target_type          = "ip"
  deregistration_delay = 30

  health_check {
    healthy_threshold   = var.lb_health_check_healthy_threshold
    unhealthy_threshold = var.lb_health_check_unhealthy_threshold
    interval            = 30
    matcher             = 200
    path                = var.lb_health_check_path
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
  }
}

data "aws_lb" "main" {
  name = "fgr-ecs-load-balancer"
}

data "aws_lb_listener" "https" {
  load_balancer_arn = data.aws_lb.main.arn
  port              = 443
}

resource "aws_alb_listener_rule" "service" {
  listener_arn = data.aws_lb_listener.https.arn

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.service.arn
  }

  condition {
    host_header {
      values = local.lb_listener_rule_host_header
    }
  }

  condition {
    path_pattern {
      values = var.lb_listener_rule_path_pattern
    }
  }

  lifecycle {
    ignore_changes = [
      priority
    ]
  }
}
