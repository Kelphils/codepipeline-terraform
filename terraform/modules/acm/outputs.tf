output "acm_certificate_arn" {
  value       = aws_acm_certificate.certificate.arn
  description = "The ARN of the certificate"
}

output "acm_cert_arn" {
  value       = aws_acm_certificate_validation.cert_validation.certificate_arn
  description = "The ARN of the certificate"
}
