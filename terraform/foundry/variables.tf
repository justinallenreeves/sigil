variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "s3_bucket_prefix" {
  type = string
}

variable "name" {
  type    = string
  default = "foundry"
}

variable "environment" {
  type    = string
  default = "prod"
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

variable "foundry_version" {
  type = string
}

variable "foundry_container_port" {
  type    = number
  default = 30000
}

variable "foundry_host_port" {
  type    = number
  default = 30000
}

variable "foundry_container_memory" {
  type    = number
  default = 512
}

variable "foundry_container_cpu" {
  type    = number
  default = 256
}

variable "foundry_timezone" {
  type    = string
  default = "EST"
}

variable "foundry_minify_static_files" {
  type    = bool
  default = true
}
