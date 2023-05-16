variable "domain_name" {
  description = "The domain name of the service"
  default     = "kelyinc.xyz"
  type        = string
}

variable "subdomain" {
  description = "The subdomain name of the service"
  default     = "wildfly"
  type        = string
}
variable "alb_dns_name" {
  description = "The domain name of the load balancer"
  type        = string
}

variable "alb_zone_id" {
  description = "The zone id of the load balancer"
  type        = string
}

variable "is_private_zone" {
  description = "Is the hosted zone private?"
  type        = bool
  default     = false
}
