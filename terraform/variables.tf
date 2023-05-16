variable "environment" {
  description = "Deployment Environment"
  default     = "staging"
  type        = string
}

variable "project" {
  description = "The name of the project"
  default     = "wildfly-compose"
  type        = string
}

variable "no_of_availability_zones" {
  description = "The number of availability zones to use for the VPC"
  default     = 3
  type        = number
}

variable "second_octet" {
  description = "The second octet of the CIDR block (10.X.0.0/16) that will be used for the VPC"
  default     = "6"
  type        = string
}

# If access needs to be restricted externally
# Remove the default allow all ip range "0.0.0.0/0" and add the ips that should be allowed to access the alb
# e.g. 125.264.1.0/32, 145.32.67.98/32
# Multiple ip ranges can be specified by separating them with a comma
# e.g. ["125.264.1.0/32", "145.32.67.98/32"]
# An empty list will remove all ip ranges and block all external traffic e.g. []
# whitelisted_ips: ["0.0.0.0/0"]
variable "whitelisted_ips" {
  description = "The IP addresses that can access the ALB"
  default     = ["0.0.0.0/0"]
  type        = list(string)
}

variable "is_internal" {
  description = "Is the load balancer internal?"
  type        = bool
  default     = false
}

