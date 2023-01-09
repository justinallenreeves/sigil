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
