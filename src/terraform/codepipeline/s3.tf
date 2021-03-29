resource "aws_s3_bucket" "cp-s3-bucket" {
  bucket = "cc-demo-cp-eu-west-2"
  acl    = "private"
  tags = {
    Name        = "codebuild-s3-bucket"
    Owner       = "code-challenge"
    Environment = "demo"
  }

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "aws:kms"
      }
    }
  }

  lifecycle_rule {
    abort_incomplete_multipart_upload_days = 5
    enabled                                = true
    id                                     = "hygiene"

    expiration {
      days                         = 100
      expired_object_delete_marker = false
    }

    noncurrent_version_expiration {
      days = 30
    }
  }
}