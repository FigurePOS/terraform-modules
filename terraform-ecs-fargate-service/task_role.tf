
resource "aws_iam_role" "ecs_task_role" {
  name               = "${var.service_name}__ecs_task"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_role_assume_policy.json
}

data "aws_iam_policy_document" "ecs_task_role_assume_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_role_default" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.ecs_task_role_default.arn
}

resource "aws_iam_policy" "ecs_task_role_default" {
  name   = "${var.service_name}__ecs_task_default"
  policy = data.aws_iam_policy_document.ecs_task_role_default.json
}


data "aws_iam_policy_document" "ecs_task_role_default" {
  statement {
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:Encrypt",
      "kms:Generate*",
    ]
    resources = [
      "arn:aws:kms:${var.aws_region}:${var.aws_account_id}:key/*",
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "ssmmessages:CreateControlChannel",
      "ssmmessages:CreateDataChannel",
      "ssmmessages:OpenControlChannel",
      "ssmmessages:OpenDataChannel",
    ]
    resources = [
      "*",
    ]
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_role_custom" {
  count      = var.task_policy != null ? 1 : 0
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.ecs_task_role_custom[0].arn
}

resource "aws_iam_policy" "ecs_task_role_custom" {
  count  = var.task_policy != null ? 1 : 0
  name   = "${var.service_name}__ecs_task_custom"
  policy = var.task_policy.json
}

