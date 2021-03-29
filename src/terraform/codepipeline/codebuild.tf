resource "aws_codebuild_project" "cc-demo-tf" {
  name         = "cc-demo-tf-build"
  service_role = aws_iam_role.cc_demo_codebuild_service_role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  cache {
    type     = "S3"
    location = aws_s3_bucket.cp-s3-bucket.bucket
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:3.0"
    privileged_mode             = true
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
  }

  source {
    type = "CODEPIPELINE"
  }

  tags = {
    Name        = "cc-demo-codepipeline"
    Owner       = "code-challenge"
    Environment = "demo"
  }
}