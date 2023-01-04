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
