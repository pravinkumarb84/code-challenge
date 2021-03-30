resource "aws_lb" "cc_scaling_lb" {
  name                       = "cc-scaling-lb"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.sg.id]
  subnets                    = aws_subnet.private.*.id
  enable_deletion_protection = false

  access_logs {
    bucket  = aws_s3_bucket.cc-scaling-lb-logs.bucket
    prefix  = "cc-scaling-lb-logs"
    enabled = true
  }

  tags = {
    Name        = "cc-scaling-lb"
    Owner       = "code-challenge"
    Environment = "demo"
    Igw_Name    = aws_internet_gateway.cc-scaling-igw.id
  }
}

resource "aws_alb_listener" "cc_scaling_listener" {
  load_balancer_arn = aws_lb.cc_scaling_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.cc_scaling_tg.arn
    type             = "forward"
  }
}

resource "aws_lb_target_group" "cc_scaling_tg" {
  name     = "cc-scaling-lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc_cc_scaling.id
  health_check {
    path = "/"
    port = 80
  }
}

resource "aws_s3_bucket" "cc-scaling-lb-logs" {
  bucket        = "cc-scaling-lb-bucket"
  acl           = "private"
  force_destroy = true

  versioning {
    enabled = true
  }

  tags = {
    Name        = "cc-scaling-lb-logs-bucket"
    Owner       = "code-challenge"
    Environment = "demo"
  }
}

data "aws_elb_service_account" "main" {}

resource "aws_s3_bucket_policy" "lb_scaling_s3_policy" {
  bucket = aws_s3_bucket.cc-scaling-lb-logs.id

  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "lb_s3_policy"
    Statement = [
      {
        Sid    = "S3_lb_access_1"
        Effect = "Allow"
        Principal = {
          "AWS" : [
            data.aws_elb_service_account.main.arn
          ]
        }
        Action = "s3:PutObject"
        Resource = [
          "arn:aws:s3:::${aws_s3_bucket.cc-scaling-lb-logs.bucket}/${aws_lb.cc_scaling_lb.access_logs[0].prefix}/AWSLogs/${local.account_id}/*",
        ]
      },
      {
        Sid    = "S3_lb_access_2"
        Effect = "Allow"
        Principal = {
          "Service" : [
            "delivery.logs.amazonaws.com",
          ]
        }
        Action = "s3:GetBucketAcl"
        Resource = [
          "arn:aws:s3:::cc-demo-lb-bucket",
        ]
      },
      {
        Sid    = "S3_lb_access_3"
        Effect = "Allow"
        Principal = {
          "Service" : [
            "delivery.logs.amazonaws.com",
          ]
        }
        Action = "s3:PutObject"
        Resource = [
          "arn:aws:s3:::${aws_s3_bucket.cc-scaling-lb-logs.bucket}/${aws_lb.cc_scaling_lb.access_logs[0].prefix}/AWSLogs/${local.account_id}/*",
        ]
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      }
    ]
  })
}

