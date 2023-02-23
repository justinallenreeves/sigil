locals {
  aws_account_id      = data.aws_caller_identity.this.account_id
  aws_region          = data.aws_region.current.name
  docker_repository  = "felddy/foundryvtt"
  docker_image       = format("%v:%v", local.docker_repository, var.foundry_version)
  ecr                 = format("%v.dkr.ecr.%v.amazonaws.com", local.aws_account_id, local.aws_region)
  ecr_image           = format("%v/%v", local.ecr, local.docker_repository)
  ecr_image_versioned = format("%v/%v:%v", local.ecr, local.docker_repository, var.foundry_version)
  ecr_image_latest    = format("%v/%v:latest", local.ecr, local.docker_repository)
}
