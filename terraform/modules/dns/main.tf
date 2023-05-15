#DNS Configuration
#Get already , publicly configured Hosted Zone on Route53 - MUST EXIST
locals {
  domain = var.is_private_zone ? join(".", ["internal", var.domain_name]) : var.domain_name
}
data "aws_route53_zone" "dns" {
  name         = local.domain
  private_zone = var.is_private_zone
}

resource "aws_route53_record" "record" {
  zone_id = data.aws_route53_zone.dns.zone_id
  name    = var.subdomain != "" ? join(".", [var.subdomain, data.aws_route53_zone.dns.name]) : data.aws_route53_zone.dns.name
  type    = "A"

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }
}
