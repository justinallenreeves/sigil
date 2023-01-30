output "sigil_vpc" {
  value = module.sigil_vpc
}

output "sigil_ecs_cluster" {
  value = aws_ecs_cluster.sigil_cluster
}

output "sigil_cloudwatch_log_group" {
  value = aws_cloudwatch_log_group.sigil_cw_lg
}
