data "aws_region" "current" {
  name = var.aws_region
}

data "aws_ecr_repository" "foundry_repository" {
  name = "foundry"
}

data "aws_ecr_image" "foundry_image" {
  repository_name = data.aws_ecr_repository.foundry_repository.name
  image_tag       = var.foundry_version
}

# data "aws_iam_role" "ecs_task_role" {
#   name = aws_iam_role.task_role.name
# }