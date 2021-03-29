resource "aws_codepipeline" "cc-demo-codepipeline" {
  name     = "cc-demo-codepipeline"
  role_arn = aws_iam_role.cc_demo_cp_service_role.arn

  artifact_store {
    location = aws_s3_bucket.cp-s3-bucket.bucket
    type     = "S3"
  }

  stage {
    name = "Source"
    action {
      name             = "Source"
      category         = "Source"
      version          = "1"
      owner            = "AWS"
      provider         = "S3"
      output_artifacts = ["output-artifact"]
      configuration = {
        S3Bucket             = aws_s3_bucket.cp-s3-bucket.bucket
        S3ObjectKey          = "cc-demo-code/main/code.zip"
        PollForSourceChanges = true
      }
    }
  }

  stage {
    name = "Deploy"
    action {
      name            = "Plan"
      category        = "Build"
      version         = "1"
      owner           = "AWS"
      provider        = "CodeBuild"
      run_order       = 1
      input_artifacts = ["output-artifact"]
      configuration = {
        ProjectName = aws_codebuild_project.cc-demo-tf.name
        EnvironmentVariables = jsonencode([
          {
            name  = "TF_STAGE"
            type  = "PLAINTEXT"
            value = "PLAN"
          }
        ])
      }
    }
    action {
      name            = "Apply"
      category        = "Build"
      version         = "1"
      owner           = "AWS"
      provider        = "CodeBuild"
      run_order       = 2
      input_artifacts = ["output-artifact"]
      configuration = {
        ProjectName = aws_codebuild_project.cc-demo-tf.name
        EnvironmentVariables = jsonencode([
          {
            name  = "TF_STAGE"
            type  = "PLAINTEXT"
            value = "APPLY"
          }
        ])
      }
    }
  }
  tags = {
    Name        = "cc-demo-codepipeline"
    Owner       = "code-challenge"
    Environment = "demo"
  }
}