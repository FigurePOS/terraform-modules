# IAM Role for Lambda
resource "aws_iam_role" "lambda_role" {
  name = var.role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

# Basic logging policy - always attach
resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# VPC access policy - attach only if vpc_subnet_ids is not empty
resource "aws_iam_role_policy_attachment" "lambda_vpc" {
  count      = length(var.vpc_subnet_ids) > 0 ? 1 : 0
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

# Custom policy for resources access
resource "aws_iam_policy" "lambda_policy" {
  count       = length(var.policy_documents) > 0 ? 1 : 0
  name        = "${var.function_name}-policy"
  description = "Custom policy for ${var.function_name} Lambda function"
  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = var.policy_documents
  })
}

resource "aws_iam_role_policy_attachment" "lambda_custom_policy" {
  count      = length(var.policy_documents) > 0 ? 1 : 0
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy[0].arn
}
