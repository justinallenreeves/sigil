locals {
  foundry_repo  = data.aws_ecr_repository.foundry_repository.repository_url
  foundry_image = "${local.foundry_repo}:${var.foundry_version}"
}

