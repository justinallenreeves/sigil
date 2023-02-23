data "aws_caller_identity" "this" {}

data "aws_region" "current" {}

data "aws_ecr_authorization_token" "token" {}

#data "aws_ecr_repository" "foundry" {
#  name = aws_ecr_repository.foundry.name # "foundry"
#}

resource "aws_ecr_repository" "foundry" {
  name = local.docker_repository
}

resource "aws_ecr_repository_policy" "foundry" {
  policy     = <<EOF
  {
    "Version": "2008-10-17",
    "Statement": [
      {
        "Sid": "adds full ecr access to the foundry repository",
        "Effect": "Allow",
        "Principal": "*",
        "Action": [
          "ecr:BatchCheckLayerAvailability",
          "ecr:BatchGetImage",
          "ecr:CompleteLayerUpload",
          "ecr:GetDownloadUrlForLayer",
          "ecr:GetLifecyclePolicy",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage",
          "ecr:UploadLayerPart"
        ]
      }
    ]
  }
  EOF
  repository = aws_ecr_repository.foundry.name
}
