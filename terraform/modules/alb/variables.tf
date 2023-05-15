variable "environment" {
  description = "the name of your environment, e.g. \"prod\""
}

variable "vpc_id" {
  description = "The VPC ID"
}

variable "whitelisted_ips" {
  description = "The IP addresses that can access the ALB"
  type        = list(string)
}

variable "is_internal" {
  description = "Is the load balancer internal?"
  type        = bool
}


# variable "aws_acm_certificate_validation_arn" {
#   description = "The ARN of the ACM certificate"
#   type        = string
# }

variable "alb_tls_cert_arn" {
  description = "The ARN of the ACM certificate"
  type        = string
}

variable "subnets" {
  description = "subnets to use for the application load balancer"
  type        = list(string)
}
