data "aws_ecr_repository" "foundry_repository" {
  name = "foundry"
}

data "aws_s3_bucket" "foundry_assets" {
  bucket = "${var.s3_bucket_prefix}.foundry.assets"
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
      "image": "${data.aws_ecr_repository.foundry_repository.repository_url}:${var.foundry_version}",
      "essential": true,
      "portMappings": [
        {
          "containerPort": ${var.foundry_container_port},
          "protocal": "tcp",
          "appProtocol": "http"
        }
      ],
      "memory": ${var.foundry_mem},
      "cpu": ${var.foundry_cpu},
      "logConfiguration": {
        "logDriver": "${var.foundry_log_driver}",
        "options": {
          "awslogs-group": "${aws_cloudwatch_log_group.sigil_clg.name}",
          "awslogs-region": "${data.aws_region.current.name}",
          "awslogs-stream-prefix": "${var.foundry_awslog_stream_prefix}"
        }
      },
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
  memory                   = var.foundry_mem
  cpu                      = var.foundry_cpu
  execution_role_arn       = aws_iam_role.task_role.arn
  lifecycle {
    ignore_changes = [container_definitions]
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
    security_groups  = [data.aws_security_group.sigil_sg.id]
  }

  load_balancer {
    target_group_arn = data.aws_lb_target_group.sigil_lb_tg.arn
    container_name   = aws_ecs_task_definition.foundry_task.family
    container_port   = 30000
  }
  lifecycle {
    ignore_changes = [tags]
  }
}

resource "aws_cloudwatch_log_group" "sigil_clg" {
  name              = "sigil-clg"
  retention_in_days = 1
}

data "aws_iam_policy_document" "ecs_task_assume_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "task_role" {
  name               = "ecs-task-foundry-${terraform.workspace}"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_policy.json

  inline_policy {
    name = "ecs-task-permissions"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action = [
            "ecr:*",
            "logs:*",
            "s3:*"
          ]
          Effect   = "Allow"
          Resource = "*"
        }
      ]
    })
  }
}

resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole_policy" {
  role       = aws_iam_role.task_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

data "aws_security_group" "sigil_sg" {
  name = "sigil-sg"
}
output "sigil_sg" {
  value = data.aws_security_group.sigil_sg
}