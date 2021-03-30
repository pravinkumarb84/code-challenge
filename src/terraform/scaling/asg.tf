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

resource "aws_launch_configuration" "cc_scaling_demo" {
  image_id        = data.aws_ami.amazon-linux-2.id
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.sg.id]
  user_data       = <<EOF
            #! /bin/bash
            sudo apt-get update -y && apt-get install -y docker.io
            docker pull nginx:latest
            docker run -d -p 80:80 --name nginx nginx
EOF
  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_autoscaling_group" "cc_scaling_asg" {
  name                      = "cc-demo-autoscaling-group"
  max_size                  = 6
  min_size                  = 1
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = 3
  launch_configuration      = aws_launch_configuration.cc_scaling_demo.id
  vpc_zone_identifier       = [aws_subnet.private[0].id, aws_subnet.private[1].id, aws_subnet.private[2].id]
  force_delete              = true
  tag {
    key                 = "Name"
    value               = "cc-scaling-asg"
    propagate_at_launch = true
  }
}
resource "aws_autoscaling_attachment" "demo_asg_attachment" {
  alb_target_group_arn   = aws_lb_target_group.cc_scaling_tg.arn
  autoscaling_group_name = aws_autoscaling_group.cc_scaling_asg.id
}