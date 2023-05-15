output "acm_cert_arn" {
  value       = module.acm.acm_cert_arn
  description = "The ARN of the certificate"
}

output "alb_dns_name" {
  value       = module.alb.alb_dns_name
  description = "The domain name of the load balancer"
}

output "subdomain_name" {
  value       = module.dns.subdomain_name
  description = "The subdomain name of the service"
}
