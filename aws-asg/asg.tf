
resource "aws_security_group" "demo" {
  name        = "demo"
  vpc_id      = aws_vpc.demo.id

  tags = {
    Name       = "demo"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_launch_template" "demo" {
  name                = "demo"
  image_id            = "ami-01748a72bed07727c"
  instance_type       = "t2.nano"

  user_data                   = base64encode(templatefile("${path.module}/user-data.tpl", {
  }))

  network_interfaces {
    associate_public_ip_address = true
    security_groups = [aws_security_group.demo.id]
  }

#   instance_market_options {
#     market_type = "spot"
#   }

  update_default_version = true

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "demo" {
  
  vpc_zone_identifier = [aws_subnet.demo_subnet_1.id]
   
  desired_capacity   = 1
  max_size           = 3
  min_size           = 1

  launch_template {
    id      = aws_launch_template.demo.id
    version = "$Latest"
  }

  tag {
    key  = "Version"
    value = aws_launch_template.demo.latest_version
    propagate_at_launch = true
  }

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
    triggers = ["tag"]
  }
}