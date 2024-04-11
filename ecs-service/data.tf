data "aws_ecs_cluster" "main" {
  cluster_name = var.ecs_cluster_name
}

data "aws_iam_policy" "ecs_task_execution_default" {
  name = "ecs_execution_default"
}

data "aws_iam_policy" "ecs_task_default" {
  name = "ecs_task_default"
}

data "aws_lb" "main" {
  name = var.lb_name
}

data "aws_lb_listener" "https" {
  load_balancer_arn = data.aws_lb.main.arn
  port              = 443
}

data "aws_security_group" "cluster" {
  filter {
    name   = "tag:Purpose"
    values = ["cluster"]
  }
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }
  filter {
    name   = "tag:Network"
    values = ["fgr-private-services"]
  }
}

data "aws_vpc" "main" {
  filter {
    name   = "tag:Purpose"
    values = ["main"]
  }
}
