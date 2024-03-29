
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
  policy_arn = data.aws_iam_policy.ecs_task_execution_default.arn
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
