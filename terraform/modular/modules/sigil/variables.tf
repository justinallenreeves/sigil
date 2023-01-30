variable "foundry_container_port" {
  type = number
}

variable "foundry_mem" {
  type = number
}

variable "foundry_cpu" {
  type = number
}

variable "foundry_timezone" {
  type = string
}

variable "foundry_minify_static_files" {
  type = string
}

variable "foundry_username" {
  type = string
}

variable "foundry_password" {
  type = string
}

variable "foundry_admin_key" {
  type = string
}

variable "foundry_license_key" {
  type = string
}

variable "ecs_task_role_arn" {
  type = string
}

variable "ecs_cluster_id" {
  type = string
}

variable "foundry_instances" {
  type = number
}

variable "foundry_version" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "vpc" {}

variable "security_group_id" {
  type = string
}

variable "target_group_arn" {
  type = string
}

variable "cloudwatch_log_group" {}
