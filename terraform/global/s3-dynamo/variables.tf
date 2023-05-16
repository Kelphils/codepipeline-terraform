variable "environment" {
  description = "Project environment"
  default     = "staging"
}

variable "project" {
  description = "The name of the project"
  default     = "wildfly-compose"
  type        = string
}
