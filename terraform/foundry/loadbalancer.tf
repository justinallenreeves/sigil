#resource "aws_alb" "sigil_lb" {
#  name               = "${var.name}-alb-${var.environment}"
#  load_balancer_type = "application"
#  subnets            = data.aws_subnet.public.*.id
#  # Referencing the security group
#  security_groups = [aws_security_group.sigil_lb_sg.id]
#
#  tags = {
#    Terraform   = "true"
#    Environment = "prod"
#  }
#}

resource "aws_security_group" "sigil_lb_sg" {
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

#resource "aws_lb_target_group" "sigil_lb_tg" {
#  name        = "sigil-lb-tg"
#  port        = 80
#  protocol    = "HTTP"
#  target_type = "ip"
#  vpc_id      = data.aws_vpc.sigil.id
#  health_check {
#    matcher = "200,301,302"
#    path    = "/"
#  }
#}

# resource "aws_lb_listener" "listener" {
#   load_balancer_arn = aws_alb.sigil_lb.arn # Referencing our load balancer
#   port              = "80"
#   protocol          = "HTTP"
#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.sigil_lb_tg.arn # Referencing our tagrte group
#   }
# }
