data "aws_region" "current" {
  name = var.aws_region
}

data "aws_ecr_repository" "foundry_repository" {
  name = "foundry"
}

module "infrastructure" {
  source = "./modules/infrastructure"
}

module "s3" {
  source = "./modules/s3"
  prefix = var.s3_bucket_prefix
  name   = "sigil-assets"
}

module "iam" {
  source        = "./modules/iam"
  assets_bucket = module.s3.assets_bucket.bucket
}

module "loadbalancer" {
  source          = "./modules/loadbalancer"
  public_subnets  = module.infrastructure.sigil_vpc.public_subnets
  private_subnets = module.infrastructure.sigil_vpc.private_subnets
  vpc_id          = module.infrastructure.sigil_vpc.vpc_id
}

module "sigil" {
  source                      = "./modules/sigil"
  aws_region                  = data.aws_region.current.name
  foundry_instances           = 1
  foundry_version             = "10.291.0"
  foundry_container_port      = 80
  foundry_mem                 = 512
  foundry_cpu                 = 256
  foundry_timezone            = "EST"
  foundry_minify_static_files = true
  foundry_username            = var.foundry_username
  foundry_password            = var.foundry_password
  foundry_admin_key           = var.foundry_admin_key
  foundry_license_key         = var.foundry_license_key
  ecs_task_role_arn           = module.iam.ecs_sigil_role.arn
  ecs_cluster_id              = module.infrastructure.sigil_ecs_cluster.id
  vpc                         = module.infrastructure.sigil_vpc
  security_group_id           = module.loadbalancer.sigil_lb_sg.id
  target_group_arn            = module.loadbalancer.sigil_lb_tg.arn
  cloudwatch_log_group        = module.infrastructure.sigil_cloudwatch_log_group
}
