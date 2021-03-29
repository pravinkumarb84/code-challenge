resource "aws_lb" "cc_demo_lb" {
  name                       = "cc-demo-lb"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.sg.id]
  subnets                    = aws_subnet.public.*.id
  enable_deletion_protection = false

  access_logs {
    bucket  = aws_s3_bucket.cc-demo-lb-logs.bucket
    prefix  = "cc-demo-lb-logs"
    enabled = true
  }

  tags = {
    Name        = "cc-demo-lb"
    Owner       = "code-challenge"
    Environment = "demo"
    Igw_Name    = aws_internet_gateway.cc-demo-igw.id
  }
}

resource "aws_lb_target_group_attachment" "cc_demo_tga" {
  target_group_arn = aws_lb_target_group.cc_demo_tg.arn
  target_id        = aws_instance.ec2-private.id
  port             = 80
}

resource "aws_alb_listener" "cc_demo_listener" {
  load_balancer_arn = aws_lb.cc_demo_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.cc_demo_tg.arn
    type             = "forward"
  }
}

resource "aws_lb_target_group" "cc_demo_tg" {
  name     = "cc-demo-lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc_cc.id
}

resource "aws_s3_bucket" "cc-demo-lb-logs" {
  bucket = "cc-demo-lb-bucket"
  acl    = "private"

  tags = {
    Name        = "cc-demo-lb-logs-bucket"
    Owner       = "code-challenge"
    Environment = "demo"
  }
}

data "aws_elb_service_account" "main" {}

resource "aws_s3_bucket_policy" "lb_s3_policy" {
  bucket = aws_s3_bucket.cc-demo-lb-logs.id

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
          "arn:aws:s3:::${aws_s3_bucket.cc-demo-lb-logs.bucket}/prefix/AWSLogs/${local.account_id}/*",
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
          "arn:aws:s3:::${aws_s3_bucket.cc-demo-lb-logs.bucket}/prefix/AWSLogs/${local.account_id}/*",
        ]
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
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
    ]
  })
}

