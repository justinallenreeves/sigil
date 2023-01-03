data "aws_ecr_repository" "foundry" {
  name = "foundry"
}

resource "aws_ecs_cluster" "sigil" {
  name = "sigil" # Naming the cluster
}

resource "aws_ecs_task_definition" "foundry_vtt_task" {
  family                   = "foundry-vtt-task" # Naming our first task
  container_definitions    = <<DEFINITION
  [
    {
      "name": "foundry-vtt-task",
      "image": "${data.aws_ecr_repository.foundry.repository_url}",
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
  requires_compatibilities = ["FARGATE"]                  # Stating that we are using ECS Fargate
  network_mode             = "awsvpc"                     # Using awsvpc as our network mode as this is required for Fargate
  memory                   = var.foundry_container_memory # Specifying the memory our container requires
  cpu                      = var.foundry_container_cpu    # Specifying the CPU our container requires
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn
}

resource "aws_ecs_service" "foundry" {
  name            = "foundry"
  cluster         = aws_ecs_cluster.sigil.id
  task_definition = aws_ecs_task_definition.foundry_vtt_task.arn
  launch_type     = "FARGATE"
  desired_count   = 1
  network_configuration {
    subnets          = data.aws_subnet.public.*.id
    assign_public_ip = true # Providing our containers with public IPs
  }
}

data "aws_vpc" "sigil" {
  filter {
    name   = "tag-value"
    values = ["sigil-vpc"]
  }
  filter {
    name   = "tag-key"
    values = ["Name"]
  }
}

data "aws_subnet" "public" {
  vpc_id = data.aws_vpc.sigil.id

  filter {
    name   = "tag:Name"
    values = ["sigil-vpc-public-*"]
  }
}
