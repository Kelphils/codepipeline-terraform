data "aws_caller_identity" "default" {}
data "aws_region" "default" {}
# The following example shows how to generate a random priority
# between 1 and 50 for each codebuild project.

resource "random_integer" "priority" {
  min = 1
  max = 50

}

resource "aws_kms_alias" "codebuild" {
  name          = "alias/KMS-KEY-${var.project}"
  target_key_id = aws_kms_key.codebuild.key_id
}

resource "aws_kms_key" "codebuild" {
  description         = "Default master key that protects my S3 objects when no other key is defined"
  enable_key_rotation = true
  policy = jsonencode(
    {
      Id = "auto-s3"
      Statement = [
        {
          Action = [
            "kms:Encrypt",
            "kms:Decrypt",
            "kms:ReEncrypt*",
            "kms:GenerateDataKey*",
            "kms:DescribeKey",
          ]
          Condition = {
            StringEquals = {
              "kms:CallerAccount" = ["${data.aws_caller_identity.default.account_id}"]
              "kms:ViaService"    = "s3.${data.aws_region.default.name}.amazonaws.com"
            }
          }
          Effect = "Allow"
          Principal = {
            AWS = "*"
          }
          Resource = "*"
          Sid      = "Allow access through S3 for all principals in the account that are authorized to use S3"
        },
        {
          Action = [
            "kms:*",
          ]
          Effect = "Allow"
          Principal = {
            AWS = ["arn:aws:iam::${data.aws_caller_identity.default.account_id}:root"]
          }
          Resource = "*"
          Sid      = "Allow direct access to key metadata to the account"
        },
      ]
      Version = "2012-10-17"
    }
  )
  tags = { Project-name = "${var.project}-${var.environment}-Kms-Key" }
}


resource "aws_codebuild_project" "build_repo" {
  name           = "${var.project}-${var.environment}-build"
  encryption_key = aws_kms_key.codebuild.arn
  service_role   = var.codebuild_role

  artifacts {
    name = "${var.project}-codebuild-artifact-${random_integer.priority.result}"
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:6.0"
    image_pull_credentials_type = "CODEBUILD"
    type                        = "LINUX_CONTAINER"
  }

  source {
    type            = "CODEPIPELINE"
    buildspec       = "buildspec.yml"
    git_clone_depth = 0
    # insecure_ssl    = false

  }
  logs_config {
    # CHANGE TO ENABLED TO ENABLE CLOUDWATCH LOGS
    cloudwatch_logs {
      group_name  = "${var.project}-${var.environment}-build-log-group"
      stream_name = "${var.project}-${var.environment}-build-log-stream"
      status      = "ENABLED"
    }
  }
  tags = { Project-name = "${var.project}-${var.environment}-Codebuild" }
}
