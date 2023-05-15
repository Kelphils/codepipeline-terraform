
locals {
  http_port       = 80
  https_port      = 443
  docker_app_port = 8069
  any_port        = 0
  any_protocol    = "-1"
  tcp_protocol    = "tcp"
  all_ips         = ["0.0.0.0/0"]
  ipv6_ips        = ["::/0"]


}

#  create a security group to allow traffic to the docker instance
resource "aws_security_group" "docker_instance_sg" {
  name        = "${var.name}-app-${var.environment}-sg"
  description = "Allow inbound traffic to the docker instance"
  vpc_id      = var.vpc_id
  tags = {
    Project-name = "${var.project}",
    Name         = "${var.name}-app-${var.environment}-sg"
  }

}

resource "aws_security_group_rule" "docker_app" {
  type                     = "ingress"
  security_group_id        = aws_security_group.docker_instance_sg.id
  protocol                 = local.tcp_protocol
  from_port                = local.docker_app_port
  to_port                  = local.docker_app_port
  source_security_group_id = var.alb_sg
}

resource "aws_security_group_rule" "allow_all_output_outbound" {
  type              = "egress"
  security_group_id = aws_security_group.docker_instance_sg.id
  description       = "Allow HTTP inbound traffic to all ports"

  # Allow all outbound requests
  from_port        = local.any_port
  to_port          = local.any_port
  protocol         = local.any_protocol
  cidr_blocks      = local.all_ips
  ipv6_cidr_blocks = local.ipv6_ips
}
