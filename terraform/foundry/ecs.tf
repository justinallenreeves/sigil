data "aws_ecr_repository" "foundry_repository" {
  name = "foundry"
}

resource "aws_ecs_cluster" "sigil_cluster" {
  name = "sigil"
}

resource "aws_ecs_task_definition" "foundry_task" {
  family                   = "foundry"
  container_definitions    = <<DEFINITION
  [
    {
      "name": "foundry",
      "image": "${data.aws_ecr_repository.foundry_repository.repository_url}",
      "essential": true,
      "portMappings": [
        {
          "containerPort": ${var.foundry_container_port},
          "hostPort": ${var.foundry_host_port}
        }
      ],
      "memory": ${var.foundry_container_memory},
      "cpu": ${var.foundry_container_cpu},
      "environment": [
        {
          "name": "TIMEZONE",
          "value": "${var.foundry_timezone}"
        },
        {
          "name": "FOUNDRY_MINIFY_STATIC_FILES",
          "value": "${var.foundry_minify_static_files}"
        },
        {
          "name": "FOUNDRY_USERNAME",
          "value": "${var.foundry_username}"
        },
        {
          "name": "FOUNDRY_PASSWORD",
          "value": "${var.foundry_password}"
        },
        {
          "name": "FOUNDRY_ADMIN_KEY",
          "value": "${var.foundry_admin_key}"
        },
        {
          "name": "FOUNDRY_LICENSE_KEY",
          "value": "${var.foundry_license_key}"
        }
      ]
    }
  ]
  DEFINITION
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  memory                   = var.foundry_container_memory
  cpu                      = var.foundry_container_cpu
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn
}

resource "aws_ecs_service" "foundry_service" {
  name            = "foundry"
  cluster         = aws_ecs_cluster.sigil_cluster.id
  task_definition = aws_ecs_task_definition.foundry_task.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    subnets          = data.aws_subnet.public.*.id
    assign_public_ip = true
  }
  # network_configuration {
  #   subnets          = data.aws_subnet.private.*.id
  #   assign_public_ip = false
  # }
  # load_balancer {
  #   target_group_arn = aws_lb_target_group.sigil_lb_tg.arn
  #   container_name   = aws_ecs_task_definition.foundry_vtt_task.family
  #   container_port   = var.foundry_container_port
  # }
}

