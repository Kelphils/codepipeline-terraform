# Repo details

variable "repository_in" {
}

variable "name_in" {
}

# Deployment details

variable "codebuild_project_name" {
  description = "The name of the CodeBuild project"
  type        = string
}

# variable "namespace" {
#   default = "global"
# }

# IAM Role, Codestar Connection

variable "code_pipeline_role_arn" {
  description = "The ARN of the CodePipeline role"
  type        = string
}

variable "project" {
  description = "The name of the project"
  default     = "wildfly-app"
  type        = string
}

variable "kms_key_arn" {
  description = "The ARN of the KMS key"
  type        = string
}

variable "codedeploy_app_name" {
  description = "The name of the Stage CodeDeploy application"
  type        = string
}

variable "codedeploy_deployment_group_name" {
  description = "The name of the Stage CodeDeploy deployment group"
  type        = string
}

variable "sns_topic_arn" {
  description = "The ARN of the SNS topic"
  type        = string
}
