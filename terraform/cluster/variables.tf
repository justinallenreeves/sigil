variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "s3_bucket_prefix" {
  type = string
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
