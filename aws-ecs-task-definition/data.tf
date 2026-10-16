data "aws_iam_policy" "ecs_task_execution_default" {
  name = "ecs_execution_default"
}

data "aws_iam_policy" "ecs_task_default" {
  name = "ecs_task_default"
}

# Fallback for task_policy / task_execution_policy when not set. An IAM policy needs at least one
# statement; sts:GetCallerIdentity is always allowed, so this grants nothing. Policies are created
# unconditionally because `count` on a possibly-unknown JSON string fails at plan time.
data "aws_iam_policy_document" "noop" {
  statement {
    actions   = ["sts:GetCallerIdentity"]
    resources = ["*"]
  }
}
