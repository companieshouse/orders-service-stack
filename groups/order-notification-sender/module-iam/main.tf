resource "aws_iam_role" "ecs-role" {
  name = var.deployment_name
  assume_role_policy = data.aws_iam_policy_document.ecs-policy.json
}

resource "aws_iam_policy" "ecs-permissions" {
  name = var.deployment_name
  policy = data.aws_iam_policy_document.ecs-permissions.json
}

resource "aws_iam_role_policy_attachment" "ecs-permissions-attachment" {
  policy_arn = aws_iam_policy.ecs-permissions.arn
  role = aws_iam_role.ecs-role.name
}

data "aws_iam_policy_document" "ecs-permissions" {
  statement {
    actions = [
      "iam:GetRole",
      "iam:PassRole",
      "ssm:GetParameters",
      "secretsmanager:GetSecretValue",
      "kms:Decrypt",
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    effect = "Allow"
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "ecs-policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["ecs-tasks.amazonaws.com"]
      type = "Service"
    }
  }
}
