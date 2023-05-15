variable "project" {
  description = "The name of the project"
  default     = "docker-app"
  type        = string
}

variable "environment" {
  description = "Deployment Environment"
  default     = "staging"
  type        = string
}
