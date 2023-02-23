provider "docker" {
  registry_auth {
    address  = local.ecr
    username = data.aws_ecr_authorization_token.token.user_name
    password = data.aws_ecr_authorization_token.token.password
  }
}

provider "aws" {
  region = "us-east-1"
  # Make it faster by skipping something
  skip_get_ec2_platforms      = true
  skip_metadata_api_check     = true
  # skip_region_validation      = true
  # skip_credentials_validation = true
  # skip_requesting_account_id  = true
    default_tags {
    tags = {
      Environment = "dev"
      Namespace   = "sigil"
      Terraform   = "true"
    }
  }
}