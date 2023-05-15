output "url" {
  value       = aws_route53_record.record.fqdn
  description = "The URL of the record"
}

output "subdomain_name" {
  value       = aws_route53_record.record.name
  description = "The subdomain name of the service"
}
