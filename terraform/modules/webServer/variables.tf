variable "aws_lb_target_group_arn" {
  description = "ARN of the target group to attach to the autoscaling group"
  type        = string
}

# variable "key_name" {
#   description = "Key to access the EC2 instance"
#   type        = string
#   default     = "mykeypair"
# }

variable "security_groups" {
  description = "Comma separated list of security groups"
  # type        = list(string)
}

variable "project" {
  description = "The name of the project"
  default     = "wildfly-app"
  type        = string
}

variable "instance_profile" {
  description = "The name of the instance profile for cw agent on Ec2 instance"
  type        = string
}

variable "subnets" {
  description = "subnets to use for the autoscaling group instances"
  type        = list(string)
}

variable "environment" {
  description = "Deployment Environment"
  default     = "staging"
  type        = string
}
