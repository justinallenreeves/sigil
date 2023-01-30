output "sigil_lb_sg" {
  value = aws_security_group.sigil_lb_sg
}

output "sigil_lb_tg" {
  value = aws_lb_target_group.sigil_lb_tg
}
