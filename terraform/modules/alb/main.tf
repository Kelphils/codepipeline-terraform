# locals {
#   http_port  = 80
#   https_port = 443
#   # wildfly_app_port     = 8069
#   any_port     = 0
#   any_protocol = "-1"
#   tcp_protocol = "tcp"
#   all_ips      = ["0.0.0.0/0"]
#   ipv6_ips     = ["::/0"]
#   # listener_port = try(aws_alb_listener.https[0].port, 80)
#   facing = var.is_internal ? "internal" : "public"

#   alb_http_default_action = {
#     type             = var.alb_tls_cert_arn != "" ? "redirect" : "fixed-response"
#     target_group_arn = null
#     redirect = var.alb_tls_cert_arn != "" ? [{
#       port        = 443
#       protocol    = "HTTPS"
#       status_code = "HTTP_301"
#     }] : []
#     fixed_response = var.alb_tls_cert_arn != "" ? [] : [{
#       content_type = "text/plain"
#       message_body = "404: page not found"
#       status_code  = "404"
#     }]
#   }
#   terratag = { Name = "CGW-${var.environment}-Application-Lb" }
# }
locals {
  http_port  = 80
  https_port = 443
  # wildfly_app_port     = 8069
  any_port     = 0
  any_protocol = "-1"
  tcp_protocol = "tcp"
  all_ips      = ["0.0.0.0/0"]
  ipv6_ips     = ["::/0"]
  # listener_port = try(aws_alb_listener.https[0].port, 80)
  facing = var.is_internal ? "internal" : "public"

  alb_http_default_action = {
    type             = "redirect"
    target_group_arn = null
    redirect = [{
      port        = 443
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }]
    fixed_response = []
  }
  terratag = { Name = "CGW-${var.environment}-ALb" }
}

#  create a security group to allow traffic to the load balancer
resource "aws_security_group" "alb_sg" {
  name        = "CGW-alb-${var.environment}-sg"
  description = "Allow inbound traffic to the load balancer"
  vpc_id      = var.vpc_id
  tags        = local.terratag
}

# resource "aws_security_group" "wildfly_instance_sg" {
#   name   = "${var.name}-ports-${var.environment}-sg"
#    description = "Allow inbound traffic to the wildfly instance"
#   vpc_id = var.vpc_id
#       tags = {
#         Project-name = "${var.project}",
#     }
# }

resource "aws_security_group_rule" "allow_http_inbound" {
  count             = length(var.whitelisted_ips) > 0 ? 1 : 0
  type              = "ingress"
  security_group_id = aws_security_group.alb_sg.id
  description       = "Allow HTTP inbound traffic on port 80"

  # Allow inbound HTTP requests
  from_port        = local.http_port
  to_port          = local.http_port
  protocol         = local.tcp_protocol
  cidr_blocks      = var.whitelisted_ips
  ipv6_cidr_blocks = local.ipv6_ips
}

resource "aws_security_group_rule" "allow_https_inbound" {
  # count             = var.alb_tls_cert_arn != "" && length(var.whitelisted_ips) > 0 ? 1 : 0
  type              = "ingress"
  security_group_id = aws_security_group.alb_sg.id
  description       = "Allow TLS inbound traffic on port 443"

  # Allow inbound HTTPS requests
  from_port        = local.https_port
  to_port          = local.https_port
  protocol         = local.tcp_protocol
  cidr_blocks      = var.whitelisted_ips
  ipv6_cidr_blocks = local.ipv6_ips
}

resource "aws_security_group_rule" "allow_all_outbound" {
  type              = "egress"
  security_group_id = aws_security_group.alb_sg.id
  description       = "Allow HTTP inbound traffic to all ports"

  # Allow all outbound requests
  from_port        = local.any_port
  to_port          = local.any_port
  protocol         = local.any_protocol
  cidr_blocks      = local.all_ips
  ipv6_cidr_blocks = local.ipv6_ips
}


# resource "aws_security_group_rule" "allow_all_output_outbound" {
#   type              = "egress"
#   security_group_id = aws_security_group.wildfly_instance_sg.id
#   description       = "Allow HTTP inbound traffic to all ports"

#   # Allow all outbound requests
#   from_port        = local.any_port
#   to_port          = local.any_port
#   protocol         = local.any_protocol
#   cidr_blocks      = local.all_ips
#   ipv6_cidr_blocks = local.ipv6_ips
# }

resource "aws_lb" "main" {
  name               = "CGW-${var.project}-${local.facing}-${var.environment}-alb"
  internal           = var.is_internal
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = var.subnets

  enable_deletion_protection = false
  tags                       = local.terratag
}

resource "aws_alb_listener" "http" {
  load_balancer_arn = aws_lb.main.id
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = local.alb_http_default_action.type
    target_group_arn = local.alb_http_default_action.target_group_arn

    dynamic "redirect" {
      for_each = local.alb_http_default_action.redirect
      iterator = redir
      content {
        port        = redir.value["port"]
        protocol    = redir.value["protocol"]
        status_code = redir.value["status_code"]
      }
    }

    dynamic "fixed_response" {
      for_each = local.alb_http_default_action.fixed_response
      iterator = fr
      content {
        content_type = fr.value["content_type"]
        message_body = fr.value["message_body"]
        status_code  = fr.value["status_code"]
      }
    }

  }
}

resource "aws_alb_listener" "https" {
  # count             = var.alb_tls_cert_arn != "" ? 1 : 0
  load_balancer_arn = aws_lb.main.id
  port              = 443
  protocol          = "HTTPS"

  ssl_policy      = "ELBSecurityPolicy-FS-1-2-Res-2020-10"
  certificate_arn = var.alb_tls_cert_arn

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found"
      status_code  = 404
    }
  }
  tags = local.terratag
}

# resource "aws_lb_listener_certificate" "certificate" {
#   count           = local.listener_port == 443 ? 1 : 0
#   listener_arn    = aws_lb.main.arn
#   certificate_arn = var.alb_tls_cert_arn
# }

# locals {
#   # terratag = { "Environment" = "${var.environment}", "ManagedBy" = "Terraform" }
#   listener_port = try(aws_lb.main[0].port, 80)
# }
