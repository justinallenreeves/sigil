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

data "aws_lb_target_group" "sigil_lb_tg" {
  name = "sigil-lb-tg"
}

data "aws_region" "current" {}

data "aws_subnets" "public" {
  filter {
    name   = "tag:Name"
    values = ["sigil-vpc-public-*"]
  }
}

data "aws_subnets" "private" {
  filter {
    name   = "tag:Name"
    values = ["sigil-vpc-private-*"]
  }
}
