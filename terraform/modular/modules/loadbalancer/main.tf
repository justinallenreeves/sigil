resource "aws_alb" "sigil_lb" {
  name               = "sigil-alb"
  load_balancer_type = "application"
  subnets            = var.public_subnets # module.vpc.public_subnets
  security_groups    = [aws_security_group.sigil_lb_sg.id]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "sigil_lb_sg" {
  name   = "sigil-sg"
  vpc_id = var.vpc_id

  ingress {
    description      = "TLS from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"] # Allowing traffic in from all sources
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"] # Allowing traffic in from all sources
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0             # Allowing any incoming port
    to_port          = 0             # Allowing any outgoing port
    protocol         = "-1"          # Allowing any outgoing protocol 
    cidr_blocks      = ["0.0.0.0/0"] # Allowing traffic out to all IP addresses
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_lb_target_group" "sigil_lb_tg" {
  name        = "sigil-lb-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id
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
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.sigil_lb_tg.arn
  }
}
