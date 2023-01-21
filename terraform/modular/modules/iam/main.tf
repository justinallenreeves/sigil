data "aws_iam_policy" "ecs_task_execution_role_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

data "aws_iam_policy_document" "ecs_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "ecs_task" {
  statement {
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    effect    = "Allow"
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "ecs_s3" {
  statement {
    actions = ["s3:*"]
    effect  = "Allow"
    resources = [
      "arn:aws:s3:::${var.foundry_assets_s3_bucket}",
      "arn:aws:s3:::${var.foundry_assets_s3_bucket}/*"
    ]
  }
}

resource "aws_iam_role" "ecs_sigil_role" {
  name               = "ecs-sigil-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role.json

  inline_policy {
    name   = "ecs-task-policy"
    policy = data.aws_iam_policy_document.ecs_task.json
  }

  inline_policy {
    name   = "ecs-s3"
    policy = data.aws_iam_policy_document.ecs_s3.json
  }

  tags = {}
  lifecycle {
    ignore_changes = [tags]
  }
}
