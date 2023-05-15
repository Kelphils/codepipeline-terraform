

data "aws_route53_zone" "dns" {
  name         = var.root_domain_name
  private_zone = false
}

// Use the AWS Certificate Manager to create an SSL cert for our domain.
// This resource won't be created until you receive the email verifying you
// own the domain and you click on the confirmation link.
# SSL Certificate
resource "aws_acm_certificate" "certificate" {
  // We want a wildcard cert so we can host subdomains later.
  domain_name = "*.${var.root_domain_name}"
  provider    = aws.acm_provider
  #   validation_method         = "EMAIL"
  validation_method = "DNS"

  // We also want the cert to be valid for the root domain even though we'll be
  // redirecting to the www. domain immediately.
  # subject_alternative_names = ["${var.subomain_name}", "www.${var.subdomain_name}"]
  tags = {
    Name = "docker_app_acm_certificate"
  }
}


resource "aws_route53_record" "record" {
  for_each = {
    for dvo in aws_acm_certificate.certificate.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.dns.zone_id
}

# comment the validation_record_fqdns line if you do DNS validation instead of Email.
resource "aws_acm_certificate_validation" "cert_validation" {
  provider                = aws.acm_provider
  certificate_arn         = aws_acm_certificate.certificate.arn
  validation_record_fqdns = [for record in aws_route53_record.record : record.fqdn]
}

# resource "aws_lb_listener_certificate" "certificate" {
#   count           = local.listener_port == 443 ? 1 : 0
#   listener_arn    = var.listener_arn
#   certificate_arn = aws_acm_certificate_validation.certificate_validation.certificate_arn
# }
