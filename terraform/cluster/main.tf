locals {
  ecr = format(
    "%v.dkr.ecr.%v.amazonaws.com",
    data.aws_caller_identity.this.account_id,
    data.aws_region.current.name
  )
}

data "aws_caller_identity" "this" {}

data "aws_region" "current" {}

data "aws_ecr_repository" "foundry_vtt" {
  name = "felddy/foundryvtt"
}

data "aws_ecr_image" "foundry_vtt" {
  repository_name = data.aws_ecr_repository.foundry_vtt.name
  image_tag       = "latest"
}

resource "aws_ecs_cluster" "sigil" {
  name = "sigil"
}

//taint to redeploy after task def changes
resource "aws_ecs_service" "foundry_1" {
  name            = "foundry-1-service"
  desired_count   = 0
  task_definition = aws_ecs_task_definition.foundry.id # "first-run-task-definition:2"
  load_balancer {
    container_name   = "foundry-1"
    container_port   = 80
    target_group_arn = "arn:aws:elasticloadbalancing:us-east-1:817831614729:targetgroup/EC2Con-Defau-FGFBGW74AKYX/7fa64026105d2d3f"
  }

  network_configuration {
    assign_public_ip = true
    security_groups  = ["sg-02002ab6fce3e69f1"]
    subnets = [
      "subnet-03e8fed4185e08e10",
      "subnet-0441451dcd8a57e73",
    ]
  }
  lifecycle {
    ignore_changes = [
      task_definition
    ]
  }
}

//taint to redeploy after task def changes
resource "aws_ecs_task_definition" "foundry" {
  container_definitions = jsonencode([{
    name = "foundry-1"
    # image = data.aws_ecr_image.foundry_vtt.repository_name
    image             = "817831614729.dkr.ecr.us-east-1.amazonaws.com/felddy/foundryvtt:latest",
    cpu               = 256
    memoryReservation = 512
    links             = []
    portMappings = [{
      containerPort = 80
      hostPort      = 80
      protocol      = "tcp"
    }]
    essential  = true
    entryPoint = []
    command    = []
    environment = [
      {
        "name" : "FOUNDRY_USERNAME",
        "value" : var.foundry_username
      },
      {
        "name" : "FOUNDRY_LICENSE_KEY",
        "value" : var.foundry_license_key
      },
      {
        "name" : "FOUNDRY_MINIFY_STATIC_FILES",
        "value" : "true"
      },
      {
        "name" : "TIMEZONE",
        "value" : "EST"
      },
      {
        "name" : "FOUNDRY_ADMIN_KEY",
        "value" : var.foundry_admin_key
      },
      {
        "name" : "FOUNDRY_PASSWORD",
        "value" : var.foundry_password
      }
    ],
    mountPoints = []
    volumesFrom = []
    dockerLabels = {
      foundry-version = "10.291.0"
    }
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = "/ecs/first-run-task-definition"
        awslogs-region        = data.aws_region.current.name
        awslogs-stream-prefix = "ecs"
      }
    }
    healthCheck = {
      command = [
        "CMD-SHELL", "./check_health.sh || exit 1"
      ]
      interval    = 5,
      timeout     = 30,
      retries     = 3,
      startPeriod = 180
    }
  }])
  family                   = "first-run-task-definition"
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = "arn:aws:iam::817831614729:role/ecsTaskExecutionRole"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  skip_destroy             = false
  tags                     = {}
  tags_all = {
    "Environment" = "dev"
    "Namespace"   = "sigil"
    "Terraform"   = "true"
  }
  lifecycle {
    ignore_changes = [
      tags,
      tags_all,
      container_definitions
    ]
  }
}

resource "aws_vpc" "this" {
  tags = {
    "Description" = "Created for ECS cluster sigil"
    "Name"        = "ECS sigil - VPC"
  }
}

resource "aws_vpc_dhcp_options" "this" {
  domain_name = "ec2.internal"
  domain_name_servers = [
    "AmazonProvidedDNS",
  ]
  tags = {}
}

resource "aws_subnet" "subnet-1" {
  cidr_block = "10.0.0.0/24"
  # map_customer_owned_ip_on_launch = false
  tags = {
    "Description" = "Created for ECS cluster sigil"
    "Name"        = "ECS sigil - Public Subnet 1"
  }
  vpc_id = aws_vpc.this.id
}

resource "aws_subnet" "subnet-2" {
  cidr_block = "10.0.1.0/24"
  # map_customer_owned_ip_on_launch = false
  tags = {
    "Description" = "Created for ECS cluster sigil"
    "Name"        = "ECS sigil - Public Subnet 2"
  }
  vpc_id = aws_vpc.this.id
}

resource "aws_route_table" "this" {
  tags = {
    "Description" = "Created for ECS cluster sigil"
    "Name"        = "ECS sigil - RouteTable"
  }
  vpc_id = aws_vpc.this.id
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags = {
    "Description" = "Created for ECS cluster sigil"
    "Name"        = "ECS sigil - InternetGateway"
  }
}

resource "aws_security_group" "ecs_allowed_ports" {
  description = "ECS Allowed Ports"
  egress = [
    {
      cidr_blocks = [
        "0.0.0.0/0",
      ]
      description      = ""
      from_port        = 0
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "-1"
      security_groups  = []
      self             = false
      to_port          = 0
    },
  ]
  ingress = [
    {
      cidr_blocks = [
        "0.0.0.0/0",
      ]
      description      = ""
      from_port        = 80
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = false
      to_port          = 80
    },
    {
      cidr_blocks      = []
      description      = ""
      from_port        = 1
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups = [
        "sg-05551cb85351de807",
      ]
      self    = false
      to_port = 65535
    },
  ]
  name                   = "EC2ContainerService-sigil-EcsSecurityGroup-B6K2VHPX5APF"
  tags = {
    "Description" = "Created for ECS cluster sigil"
    "Name"        = "ECS sigil - ECS SecurityGroup"
  }
  vpc_id = aws_vpc.this.id

  timeouts {}
}

resource "aws_security_group" "elb_allowed_ports" {
  description = "ELB Allowed Ports"
  egress = [
    {
      cidr_blocks = [
        "0.0.0.0/0",
      ]
      description      = ""
      from_port        = 0
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "-1"
      security_groups  = []
      self             = false
      to_port          = 0
    },
  ]
  ingress = [
    {
      cidr_blocks = [
        "0.0.0.0/0",
      ]
      description      = ""
      from_port        = 80
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = false
      to_port          = 80
    },
  ]
  name                   = "EC2ContainerService-sigil-AlbSecurityGroup-ZLGNRNEWBTGE"
  tags = {
    "Description" = "Created for ECS cluster sigil"
    "Name"        = "ECS sigil - ALB SecurityGroup"
  }
  vpc_id = aws_vpc.this.id

  timeouts {}
}
