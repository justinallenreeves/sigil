locals {
  foundry_repo      = data.aws_ecr_repository.foundry_repository.repository_url
  foundry_image_tag = data.aws_ecr_image.foundry_image.image_tag
  foundry_image     = "${local.foundry_repo}:${local.foundry_image_tag}"
  foundry_container_def = {
    name         = "foundry"
    image        = local.foundry_image_tag
    essential    = true
    portMappings = [{ containerPort = var.foundry_container_port }]
    memory       = var.foundry_mem
    cpu          = var.foundry_cpu
    # logConfiguration = {
    #   logDriver = var.foundry_log_driver
    #   options = {
    #     awslogs-group         = aws_cloudwatch_log_group.sigil_clg.name
    #     awslogs-region        = data.aws_region.current.name
    #     awslogs-stream-prefix = var.foundry_awslog_stream_prefix
    #   }
    # }
    environment = [
      { name = "TIMEZONE", value = var.foundry_timezone },
      { name = "FOUNDRY_MINIFY_STATIC_FILES", value = var.foundry_minify_static_files },
      { name = "FOUNDRY_USERNAME", value = var.foundry_username },
      { name = "FOUNDRY_PASSWORD", value = var.foundry_password },
      { name = "FOUNDRY_ADMIN_KEY", value = var.foundry_admin_key },
      { name = "FOUNDRY_LICENSE_KEY", value = var.foundry_license_key },
    ]
  }
}

resource "aws_ecs_task_definition" "foundry_task" {
  family                   = "foundry"
  container_definitions    = jsonencode([local.foundry_container_def])
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  memory                   = var.foundry_mem
  cpu                      = var.foundry_cpu
  execution_role_arn       = aws_iam_role.ecs_sigil_role.arn
  lifecycle {
    ignore_changes = [container_definitions]
  }
}

resource "aws_ecs_service" "foundry_service" {
  name            = "foundry"
  cluster         = aws_ecs_cluster.sigil_cluster.id
  task_definition = aws_ecs_task_definition.foundry_task.arn
  launch_type     = "FARGATE"
  desired_count   = var.foundry_instances

  # Connect directly, insecure
  network_configuration {
    subnets          = module.sigil_vpc.public_subnets
    assign_public_ip = true
  }

  deployment_circuit_breaker {
    enable   = true  # stop consuming resources when task fails
    rollback = false # just fail fast
  }

  lifecycle {
    ignore_changes = [tags]
  }
}

#For later, try with an alb
#resource "aws_ecs_service" "foundry_service" {
#  name            = "foundry"
#  cluster         = aws_ecs_cluster.sigil_cluster.id
#  task_definition = aws_ecs_task_definition.foundry_task.arn
#  launch_type     = "FARGATE"
#  desired_count   = var.foundry_instances
#
#  network_configuration {
#    subnets          = module.sigil_vpc.private_subnets
#    assign_public_ip = false
#    security_groups  = [data.aws_security_group.sigil_sg.id]
#  }
#
#  load_balancer {
#    target_group_arn = data.aws_lb_target_group.sigil_lb_tg.arn
#    container_name   = aws_ecs_task_definition.foundry_task.family
#    container_port   = 30000
#  }
#
#  deployment_circuit_breaker {
#    enable   = true  # stop consuming resources when task fails
#    rollback = false # just fail fast
#  }
#
#  lifecycle {
#    ignore_changes = [tags]
#  }
#}

output "service_count" {
  value = aws_ecs_service.foundry_service.desired_count
}