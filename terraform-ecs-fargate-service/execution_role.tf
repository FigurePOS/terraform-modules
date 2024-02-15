
resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "${var.service_name}__ecs_task_execution"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_execution_role_assume_policy.json
}

data "aws_iam_policy_document" "ecs_task_execution_role_assume_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_service" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_default" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.ecs_task_execution_role_default.arn
}

resource "aws_iam_policy" "ecs_task_execution_role_default" {
  name   = "${var.service_name}__ecs_execution_default"
  policy = data.aws_iam_policy_document.ecs_task_execution_role_default.json
}

data "aws_iam_policy_document" "ecs_task_execution_role_default" {
  statement {
    effect = "Allow"
    actions = [
      "kms:Decrypt",
    ]
    resources = [
      "arn:aws:kms:${var.aws_region}:${var.aws_account_id}:alias/aws/ssm",
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "ssm:GetParameters",
      "ssm:DescribeParameters",
    ]
    resources = [
      "arn:aws:ssm:${var.aws_region}:${var.aws_account_id}:parameter/*",
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "logs:*",
    ]
    resources = [
      "arn:aws:logs:${var.aws_region}:${var.aws_account_id}:*",
    ]
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_custom" {
  count      = var.task_execution_policy != null ? 1 : 0
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.ecs_task_execution_role_custom[0].arn
}

resource "aws_iam_policy" "ecs_task_execution_role_custom" {
  count      = var.task_execution_policy != null ? 1 : 0
  name   = "${var.service_name}__ecs_execution_custom"
  policy = var.task_execution_policy.json
}
