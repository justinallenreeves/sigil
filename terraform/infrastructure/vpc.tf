data "aws_availability_zones" "available" {
  state = "available"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "sigil-vpc"
  cidr = "10.0.0.0/16"

  azs                = ["us-east-1a", "us-east-1b"]
  private_subnets    = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets     = ["10.0.101.0/24", "10.0.102.0/24"]
  enable_nat_gateway = false
  enable_vpn_gateway = false

  tags = {
    Terraform   = "true"
    Environment = "prod"
  }

}

output "vpc" {
  value = module.vpc.name
}

output "availability_zones" {
  value = module.vpc.azs
}

output "public_subnets" {
  value = module.vpc.public_subnets
}

output "private_subnets" {
  value = module.vpc.private_subnets
}

resource "aws_ec2_tag" "public_subnets" {
  for_each    = toset(module.vpc.public_subnets)
  resource_id = each.value
  key         = "Tier"
  value       = "public"
}

resource "aws_ec2_tag" "private_subnets" {
  for_each    = toset(module.vpc.private_subnets)
  resource_id = each.value
  key         = "Tier"
  value       = "private"
}
