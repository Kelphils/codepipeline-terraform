variable "alb_sg" {
  description = "The ID of the security group for the ALB"
  type        = string
}


variable "name" {
  description = "the name of your stack, e.g. \"demo\""
  default     = "wildfly"
}

variable "environment" {
  description = "Deployment Environment"
  #   default     = "staging"
  type = string
}

variable "project" {
  description = "The name of the project"
  default     = "wildfly-app"
  type        = string
}

variable "vpc_id" {
  description = "The VPC ID"
  type        = string
}

