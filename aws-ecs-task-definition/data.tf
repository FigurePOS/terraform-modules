data "aws_iam_policy" "ecs_task_execution_default" {
  name = "ecs_execution_default"
}

data "aws_iam_policy" "ecs_task_default" {
  name = "ecs_task_default"
}

data "aws_lb" "main" {
  name = "fgr-ecs-load-balancer"
}

