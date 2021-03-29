resource "aws_iam_role" "cc_demo_cp_service_role" {
  name                  = "CP_service_role"
  path                  = "/"
  description           = "CodePipeline Service role"
  assume_role_policy    = data.aws_iam_policy_document.cp_service_role_assume_rp.json
  force_detach_policies = true
  tags = {
    Name        = "cp-service-role"
    Owner       = "code-challenge"
    Environment = "demo"
  }
}

data "aws_iam_policy_document" "cp_service_role_assume_rp" {
  statement {
    sid     = "CPAssumeRole"
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "cp_service_policy" {
  statement {
    effect    = "Allow"
    actions   = ["s3:*"]
    resources = ["*"]
  }

  statement {
    effect    = "Allow"
    actions   = ["codebuild:*"]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy_attachment" "cp_policy_attachment" {
  role       = aws_iam_role.cc_demo_cp_service_role.name
  policy_arn = aws_iam_policy.cp_s3_access.arn
}

resource "aws_iam_policy" "cp_s3_access" {
  name        = "cp_s3_access"
  description = "cp_s3_access"
  policy      = data.aws_iam_policy_document.cp_service_policy.json

}

resource "aws_iam_role" "cc_demo_codebuild_service_role" {
  name                  = "codebuild_service_role"
  path                  = "/"
  description           = "Codebuild Service role"
  assume_role_policy    = data.aws_iam_policy_document.codebuild_service_role_assume_rp.json
  force_detach_policies = true
  tags = {
    Name        = "codebuild-service-role"
    Owner       = "code-challenge"
    Environment = "demo"
  }
}

data "aws_iam_policy_document" "codebuild_service_role_assume_rp" {
  statement {
    sid     = "CBAssumeRole"
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "cb_service_policy" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "arn:aws:logs:${local.region}:${local.account_id}:log-group:/aws/codebuild/${aws_codebuild_project.cc-demo-tf.name}",
      "arn:aws:logs:${local.region}:${local.account_id}:log-group:/aws/codebuild/${aws_codebuild_project.cc-demo-tf.name}:*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetBucketAcl",
      "s3:GetBucketLocation"
    ]
    resources = ["arn:aws:s3:::codepipeline-eu-west-2-*"]
  }

  statement {
    effect    = "Allow"
    actions   = ["s3:*"]
    resources = ["*"]
  }

  statement {
    effect    = "Allow"
    actions   = ["sts:AssumeRole"]
    resources = ["arn:aws:iam::${local.account_id}:role/${aws_iam_role.cc_demo_codebuild_service_role.name}",]
  }

  statement {
    effect    = "Allow"
    actions   = [
      "dynamodb:GetItem",
      "dynamodb:BatchGetItem",
      "dynamodb:Query",
      "dynamodb:PutItem",
      "dynamodb:UpdateItem",
      "dynamodb:DeleteItem",
      "dynamodb:BatchWriteItem"
    ]
    resources = [
      "arn:aws:dynamodb:${local.region}:${local.account_id}:table/terraform-lock"
    ]
  }

  statement {
    effect    = "Allow"
    actions   = [
      "iam:GetRole",
      "iam:ListRolePolicies",
      "iam:ListAttachedRolePolicies"
    ]
    resources = [
      "arn:aws:iam::${local.account_id}:role/*"
    ]
  }

  statement {
    effect    = "Allow"
    actions   = [
      "iam:GetPolicy",
      "iam:GetPolicyVersion"
    ]
    resources = [
      "arn:aws:iam::${local.account_id}:policy/*"
    ]
  }

  statement {
    effect    = "Allow"
    actions   = [
      "iam:GetInstanceProfile"
    ]
    resources = [
      "arn:aws:iam::${local.account_id}:instance-profile/*"
    ]
  }

  statement {
    effect    = "Allow"
    actions   = [
      "ec2:*"
    ]
    resources = [
      "*"
    ]
  }

  statement {
    effect    = "Allow"
    actions   = [
      "elasticloadbalancing:*"
    ]
    resources = [
      "*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "codebuild:CreateReportGroup",
      "codebuild:CreateReport",
      "codebuild:UpdateReport",
      "codebuild:BatchPutTestCases",
      "codebuild:BatchPutCodeCoverages"
    ]
    resources = [
      "arn:aws:codebuild:${local.region}:${local.account_id}:report-group/${aws_codebuild_project.cc-demo-tf.name}-*"
    ]
  }
}

resource "aws_iam_role_policy_attachment" "cb_policy_attachment" {
  role       = aws_iam_role.cc_demo_codebuild_service_role.name
  policy_arn = aws_iam_policy.cb_access.arn
}

resource "aws_iam_policy" "cb_access" {
  name        = "codebuild_access"
  description = "codebuild_access"
  policy      = data.aws_iam_policy_document.cb_service_policy.json

}