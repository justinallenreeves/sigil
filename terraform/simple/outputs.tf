output "foundry_container_def" {
  value = {
    name         = local.foundry_container_def.name
    image        = local.foundry_container_def.image
    portMappings = local.foundry_container_def.portMappings
    memory       = local.foundry_container_def.memory
    cpu          = local.foundry_container_def.cpu
    # logConfiguration = local.foundry_container_def.logConfiguration
  }
}

output "sigil_vpc" {
  value = {
    vpc             = module.sigil_vpc.vpc_id,
    public_subnets  = module.sigil_vpc.public_subnets.*,
    private_subnets = module.sigil_vpc.private_subnets.*
  }
}

#output "foundry_task_role" {
#  value = aws_iam_role.foundry_task_role
#}

output "foundry_assets_s3" {
  value = aws_s3_bucket.foundry_assets
}
