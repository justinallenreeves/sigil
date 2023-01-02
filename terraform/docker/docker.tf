locals {
  foundry_repository = "felddy/foundryvtt"
  foundry_image      = format("%v:%v", local.foundry_repository, var.foundry_version)
  ecr_address        = format("%v.dkr.ecr.%v.amazonaws.com", data.aws_caller_identity.this.account_id, data.aws_region.current.name)
  ecr_image          = format("%v/%v:%v", local.ecr_address, data.aws_ecr_repository.foundry.id, local.foundry_image)
}

data "aws_caller_identity" "this" {}

data "aws_region" "current" {}

data "aws_ecr_authorization_token" "token" {}

data "aws_ecr_repository" "foundry" {
  name = "foundry"
}

data "docker_registry_image" "foundry" {
  name = local.foundry_image
}

resource "docker_image" "foundry" {
  name          = data.docker_registry_image.foundry.name
  pull_triggers = [data.docker_registry_image.foundry.sha256_digest]
  keep_locally  = false
}

resource "docker_tag" "foundry" {
  source_image = docker_image.foundry.name
  target_image = local.ecr_image
}

resource "null_resource" "docker_login" {
  triggers = {
    token_expired = data.aws_ecr_authorization_token.token.expires_at
  }

  provisioner "local-exec" {
    command = "echo ${data.aws_ecr_authorization_token.token.password} docker login --username ${data.aws_ecr_authorization_token.token.user_name} --password-stdin ${data.aws_ecr_authorization_token.token.proxy_endpoint}"
  }
}

resource "null_resource" "docker_push" {
  depends_on = [
    docker_image.foundry,
    docker_tag.foundry,
    null_resource.docker_login
  ]
  triggers = {
    source_image = docker_tag.foundry.source_image
    target_image = docker_tag.foundry.target_image
  }
  provisioner "local-exec" {
    when    = create
    command = "docker push ${docker_tag.foundry.target_image}"
  }
}
