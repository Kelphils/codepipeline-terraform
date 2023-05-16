variable "codebuild_role" {
  description = "The ARN of the CodeBuild role"
  type        = string
}


variable "project" {
  description = "The name of the project"
  default     = "wildfly-app"
  type        = string
}

variable "environment" {
  description = "Deployment Environment"
  default     = "staging"
  type        = string
}
