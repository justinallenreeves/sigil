resource "aws_alb" "sigil_lb" {
  name               = "sigil-alb"
  load_balancer_type = "application"
  subnets            = module.vpc.public_subnets
  security_groups    = [aws_security_group.sigil_lb_sg.id]

  tags = {
    Terraform   = "true"
    Environment = "prod"
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "sigil_lb_sg" {
  vpc_id = module.vpc.vpc_id
  ingress {
    from_port   = 80 # Allowing traffic in from port 80
    to_port     = 30000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allowing traffic in from all sources
  }

  egress {
    from_port   = 0             # Allowing any incoming port
    to_port     = 0             # Allowing any outgoing port
    protocol    = "-1"          # Allowing any outgoing protocol 
    cidr_blocks = ["0.0.0.0/0"] # Allowing traffic out to all IP addresses
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

resource "aws_lb_target_group" "sigil_lb_tg" {
  name        = "sigil-lb-tg"
  port        = 30000
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = module.vpc.vpc_id
  health_check {
    matcher = "200,301,302"
    path    = "/"
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener" "listener" {
  depends_on = [
    aws_lb_target_group.sigil_lb_tg
  ]
  load_balancer_arn = aws_alb.sigil_lb.arn
  port              = 30000
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.sigil_lb_tg.arn
  }
}
