data "aws_ami" "amazon-linux-2" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"]
}

locals {
  count = length(var.az_list)
}

resource "aws_instance" "ec2-private" {
  ami                    = data.aws_ami.amazon-linux-2.id
  instance_type          = "t3.micro"
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.id
  subnet_id              = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.sg.id]
  tags = {
    Name        = "ec2-private-sub"
    Owner       = "code-challenge"
    Environment = "demo"
  }
}

resource "aws_instance" "ec2-public" {
  ami                    = data.aws_ami.amazon-linux-2.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public[0].id
  vpc_security_group_ids = [aws_security_group.sg.id]
  tags = {
    Name        = "ec2-public-sub"
    Owner       = "code-challenge"
    Environment = "demo"
  }
  user_data = <<EOF
            #! /bin/bash
            sudo apt-get -y update
            sudo apt-get -y install nginx
            sudo service nginx start
EOF
}