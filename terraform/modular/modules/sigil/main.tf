
locals {
  foundry_repo      = data.aws_ecr_repository.foundry_repository.repository_url
  foundry_image_tag = data.aws_ecr_image.foundry_image.image_tag
}

data "aws_region" "current" {
  name = var.aws_region
}

data "aws_ecr_repository" "foundry_repository" {
  name = "foundry"
}

data "aws_ecr_image" "foundry_image" {
  repository_name = data.aws_ecr_repository.foundry_repository.name
  image_tag       = var.foundry_version
}

resource "aws_ecs_task_definition" "foundry_task" {
  family = "foundry"
  container_definitions = jsonencode([{
    name         = "foundry"
    image        = local.foundry_image_tag
    essential    = true
    portMappings = [{ containerPort = 80 }]
    memory       = var.foundry_mem
    cpu          = var.foundry_cpu
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = var.cloudwatch_log_group.name
        awslogs-region        = data.aws_region.current.name
        awslogs-stream-prefix = "foundry-sigil"
      }
    }
    environment = [
      { name = "TIMEZONE", value = var.foundry_timezone },
      { name = "FOUNDRY_MINIFY_STATIC_FILES", value = var.foundry_minify_static_files },
      { name = "FOUNDRY_USERNAME", value = var.foundry_username },
      { name = "FOUNDRY_PASSWORD", value = var.foundry_password },
      { name = "FOUNDRY_ADMIN_KEY", value = var.foundry_admin_key },
      { name = "FOUNDRY_LICENSE_KEY", value = var.foundry_license_key }
    ]
  }])
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  memory                   = var.foundry_mem
  cpu                      = var.foundry_cpu
  execution_role_arn       = var.ecs_task_role_arn
  lifecycle {
    ignore_changes = [container_definitions]
  }
}

resource "aws_ecs_service" "foundry_service" {
  name    = "foundry"
  cluster = var.ecs_cluster_id
  # task_definition = "${aws_ecs_task_definition.foundry_task.family}:${aws_ecs_task_definition.foundry_task.revision}"
  task_definition = aws_ecs_task_definition.foundry_task.arn
  launch_type     = "FARGATE"
  desired_count   = var.foundry_instances

  network_configuration {
    subnets          = var.vpc.private_subnets
    assign_public_ip = false
    security_groups  = [var.security_group_id]
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = aws_ecs_task_definition.foundry_task.family
    container_port   = 80
  }

  deployment_circuit_breaker {
    enable   = true  # stop consuming resources when task fails
    rollback = false # just fail fast
  }

  lifecycle {
    ignore_changes = [tags]
  }

  depends_on = [
    aws_ecs_task_definition.foundry_task
  ]
}
