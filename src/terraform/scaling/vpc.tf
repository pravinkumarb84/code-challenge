resource "aws_vpc" "vpc_cc_scaling" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name        = "code-challenge-vpc-scaling"
    Owner       = "code-challenge"
    Environment = "demo"
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.vpc_cc_scaling.id
  map_public_ip_on_launch = "true"
  availability_zone       = element(var.az_list, count.index)
  cidr_block              = element(var.public_subnets_cidr, count.index)
  count                   = length(var.az_list)
  tags = {
    Name        = "subnet-pub-scaling-${count.index}"
    Owner       = "code-challenge"
    Environment = "demo"
  }
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.vpc_cc_scaling.id
  availability_zone = element(var.az_list, count.index)
  cidr_block        = element(var.private_subnets_cidr, count.index)
  count             = length(var.az_list)
  tags = {
    Name        = "subnet-priv-scaling-${count.index}"
    Owner       = "code-challenge"
    Environment = "demo"
  }
}

resource "aws_internet_gateway" "cc-scaling-igw" {
  vpc_id = aws_vpc.vpc_cc_scaling.id

  tags = {
    Name        = "cc-scaling-igw"
    Owner       = "code-challenge"
    Environment = "demo"
  }
}
