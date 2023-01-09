# Lookups for ../infrastructure/*
data "aws_vpc" "sigil" {
  filter {
    name   = "tag-value"
    values = ["sigil-vpc"]
  }
  filter {
    name   = "tag-key"
    values = ["Name"]
  }
}

data "aws_subnet" "public" {
  vpc_id = data.aws_vpc.sigil.id

  filter {
    name   = "tag:Name"
    values = ["sigil-vpc-public-*"]
  }
}

data "aws_subnet" "private" {
  vpc_id = data.aws_vpc.sigil.id

  filter {
    name   = "tag:Name"
    values = ["sigil-vpc-private-*"]
  }
}

data "aws_security_groups" "sigil-sg" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.sigil.id]
  }
}

data "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"
}

data "aws_iam_role" "foundry_s3_access" {
  name = "foundry-s3-access"
}

data "aws_region" "current" {}
