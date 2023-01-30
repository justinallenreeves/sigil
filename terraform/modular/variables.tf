variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "s3_bucket_prefix" {
  type = string
}

variable "foundry_ec2_ami" {
  type    = string
  default = "ami-09d3b3274b6c5d4aa"
}

variable "foundry_password" {
  type      = string
  sensitive = true
}
variable "foundry_username" {
  type      = string
  sensitive = true
}

variable "foundry_admin_key" {
  type      = string
  sensitive = true
}

variable "foundry_license_key" {
  type      = string
  sensitive = true
}
