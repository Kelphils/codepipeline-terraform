data "aws_caller_identity" "default" {}
resource "aws_codepipeline" "pipeline" {
  name     = "${var.project}-pipeline"
  role_arn = var.code_pipeline_role_arn

  artifact_store {
    location = aws_s3_bucket.codepipeline_bucket.bucket
    type     = "S3"
    encryption_key {
      id   = var.kms_key_arn
      type = "KMS"
    }
  }


  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_artifact"]

      configuration = {
        ConnectionArn    = aws_codestarconnections_connection.github_codepipeline.arn
        FullRepositoryId = "${var.repository_in}"
        BranchName       = "master"
        DetectChanges    = false
        # PollForSourceChanges = "true"
      }
    }
  }

  stage {
    name = "Build"


    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_artifact"]
      output_artifacts = ["build_artifact"]
      version          = "1"

      configuration = {
        ProjectName = "${var.codebuild_project_name}"
      }
    }
  }

  stage {
    name = "Deploy_Stage"

    action {
      name             = "Deploy"
      version          = "1"
      category         = "Deploy"
      owner            = "AWS"
      provider         = "CodeDeploy"
      input_artifacts  = ["build_artifact"]
      output_artifacts = []
      run_order        = 1

      configuration = {
        ApplicationName     = var.codedeploy_app_name
        DeploymentGroupName = var.codedeploy_deployment_group_name
      }
    }


  }
  stage {
    name = "Manual_Approval"
    action {
      name     = "Manual-Approval"
      category = "Approval"
      owner    = "AWS"
      provider = "Manual"
      version  = "1"
    }
  }

  #   stage {
  #     name = "Deploy_Prod"

  #     action {
  #       name             = "Deploy"
  #       version          = "1"
  #       category         = "Deploy"
  #       owner            = "AWS"
  #       provider         = "CodeDeploy"
  #       input_artifacts  = ["build_artifact"]
  #       output_artifacts = []
  #       run_order        = 1

  #       configuration = {
  #         ApplicationName     = var.codedeploy_app_name_2
  #         DeploymentGroupName = var.codedeploy_deployment_group_name_2
  #       }
  #     }


  #   }

  tags = { Project-name = "${var.project}-${var.environment}-Pipeline" }
}


resource "aws_codestarnotifications_notification_rule" "notifications" {
  detail_type    = "FULL"
  event_type_ids = ["codepipeline-pipeline-action-execution-succeeded", "codepipeline-pipeline-action-execution-failed", "codepipeline-pipeline-stage-execution-failed", "codepipeline-pipeline-pipeline-execution-failed", "codepipeline-pipeline-manual-approval-failed", "codepipeline-pipeline-manual-approval-needed", "codepipeline-pipeline-manual-approval-succeeded"]

  name     = "${var.project}-pipeline-notification"
  resource = aws_codepipeline.pipeline.arn

  target {
    address = var.sns_topic_arn
  }
}
resource "aws_codestarconnections_connection" "github_codepipeline" {
  name          = "${var.project}-github-codepipeline"
  provider_type = "GitHub"
}

resource "aws_s3_bucket" "codepipeline_bucket" {
  bucket        = "${var.project}-codepipeline-bucket-${data.aws_caller_identity.default.account_id}"
  force_destroy = true


  # Prevent accidental deletion of this S3 bucket
  lifecycle {
    prevent_destroy = false
  }
  tags = { Project-name = "${var.project}-${var.environment}-bucket" }
}

resource "aws_s3_bucket_versioning" "enabled" {
  bucket = aws_s3_bucket.codepipeline_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}


# Enable server-side encryption by default
resource "aws_s3_bucket_server_side_encryption_configuration" "default" {
  bucket = aws_s3_bucket.codepipeline_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Explicitly block all public access to the S3 bucket
# resource "aws_s3_bucket_public_access_block" "public_access" {
#   bucket                  = aws_s3_bucket.codepipeline_bucket.id
#   block_public_acls       = true
#   block_public_policy     = true
#   ignore_public_acls      = true
#   restrict_public_buckets = true
# }

resource "aws_s3_bucket_ownership_controls" "codepipeline_bucket" {
  bucket = aws_s3_bucket.codepipeline_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "codepipeline_bucket" {
  depends_on = [aws_s3_bucket_ownership_controls.codepipeline_bucket]

  bucket = aws_s3_bucket.codepipeline_bucket.id
  acl    = "private"
}
