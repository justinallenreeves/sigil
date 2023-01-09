data "aws_ecr_repository" "foundry_repository" {
  name = "foundry"
}

data "aws_s3_bucket" "foundry_assets" {
  bucket = "${var.s3_bucket_prefix}.foundry.assets"
}

resource "aws_ecs_cluster" "sigil_cluster" {
  name = "sigil"
}

# "logConfiguration": {
#   "logDriver": "awslogs",
#   "options": {
#     "awslogs-group": "${var.cloudwatch_group}",
#     "awslogs-region": "${data.aws_region.current.value}",
#     "awslogs-stream-prefix": "ecs"
#   }
# },

resource "aws_ecs_task_definition" "foundry_task" {
  family                   = "foundry"
  container_definitions    = <<DEFINITION
  [
    {
      "name": "foundry",
      "image": "${data.aws_ecr_repository.foundry_repository.repository_url}:${var.foundry_version}",
      "essential": true,
      "portMappings": [
        {
          "containerPort": 30000,
          "protocal": "tcp",
          "appProtocol": "http"
        }
      ],
      "memory": 512,
      "cpu": 256,
      "environment": [
        {
          "name": "TIMEZONE",
          "value": "EST"
        },
        {
          "name": "FOUNDRY_MINIFY_STATIC_FILES",
          "value": "true"
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
  # runtime_platform {
  #   operating_system_family = "LINUX"
  #   cpu_architecture        = "X86_64"
  # }
  network_mode       = "awsvpc"
  memory             = 512
  cpu                = 256
  execution_role_arn = data.aws_iam_role.ecs_task_execution_role.arn
  task_role_arn      = data.aws_iam_role.foundry_s3_access.arn
  # volume {
  #   name      = "storage"
  #   host_path = "/ecs/service-storage"
  # }
  lifecycle {
    ignore_changes = [container_definitions]
  }
}

output "foundry_container_definitions" {
  value = {
    arn                = aws_ecs_task_definition.foundry_task.arn
    family             = aws_ecs_task_definition.foundry_task.family
    memory             = aws_ecs_task_definition.foundry_task.memory
    cpu                = aws_ecs_task_definition.foundry_task.memory
    execution_role_arn = aws_ecs_task_definition.foundry_task.execution_role_arn
    task_role_arn      = aws_ecs_task_definition.foundry_task.task_role_arn
    runtime_platform   = aws_ecs_task_definition.foundry_task.runtime_platform
  }
}

resource "aws_ecs_service" "foundry_service" {
  name            = "foundry"
  cluster         = aws_ecs_cluster.sigil_cluster.id
  task_definition = aws_ecs_task_definition.foundry_task.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    subnets          = data.aws_subnets.private.ids
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = data.aws_lb_target_group.sigil_lb_tg.arn
    container_name   = aws_ecs_task_definition.foundry_task.family
    container_port   = 30000
  }
}

output "foundry_service" {
  value = aws_ecs_service.foundry_service
}
