data "aws_iam_policy_document" "s3_access" {
  statement {
    sid     = "S3Access"
    effect  = "Allow"
    actions = ["s3:*", ]
    resources = [
      "*",
    ]
  }
}

resource "aws_iam_role" "ec2_s3_role" {
  name                  = "EC2_instance_role"
  path                  = "/"
  assume_role_policy    = data.aws_iam_policy_document.ec2_policy.json
  force_detach_policies = true
}

data "aws_iam_policy_document" "ec2_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}


resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2_profile"
  role = aws_iam_role.ec2_s3_role.name
}

resource "aws_iam_role_policy_attachment" "ec2_s3_policy_attachment" {
  role       = aws_iam_role.ec2_s3_role.name
  policy_arn = aws_iam_policy.cc-demo-s3-access.arn
}

resource "aws_iam_policy" "cc-demo-s3-access" {
  name        = "cc-demo-s3-access"
  description = "cc-demo-s3-access"
  policy      = data.aws_iam_policy_document.s3_access.json

}