variable "environment" {
  description = "Project environment"
  default     = "staging"
}

variable "project" {
  description = "The name of the project"
  default     = "docker-compose"
  type        = string
}
