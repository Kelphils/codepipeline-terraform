terraform {

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  #   backend configuration for the terraform state in S3 bucket with the DynamoDb table as the backend and encryption, locking enabled
  #  Always remember to run terraform init command like this due to backend.hcl file include
  # terraform init -backend-config=backend.hcl
  backend "s3" {
    key = "infra/staging/terraform.tfstate"

  }
}

#  configure the aws provider
provider "aws" {
  region  = "eu-west-2"
  profile = "default"
  default_tags {
    tags = {
      Owner = "ManagedBy-Terraform",
      #   Project-name = "${var.project}",
      Environment = "${var.environment}"
    }
  }
}
