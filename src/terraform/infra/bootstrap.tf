provider "aws" {
  region  = "eu-west-2"
  profile = "code-challenge"
  #assume_role {
  #  role_arn = var.role_arn
  #}
}

terraform {
  backend "s3" {
    dynamodb_table = "terraform-lock"
    encrypt        = true
  }
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  region     = data.aws_region.current.name
  account_id = data.aws_caller_identity.current.account_id
}