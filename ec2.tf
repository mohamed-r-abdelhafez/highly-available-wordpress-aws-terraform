data "aws_ami" "amzn_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}



resource "aws_key_pair" "wordpress-key" {
  key_name   = var.ec2-public-key-name
  public_key = file(var.ec2-public-key-path)
}

resource "aws_launch_template" "bastion-LT" {
  name          = "Bastion-Host"
  description   = "Launch Template for the Bastion instances"
  image_id      = data.aws_ami.amzn_linux.id
  instance_type = var.instance-type-bs
  key_name      = var.ec2-public-key-name
  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.bastion-sg.id]
  }
  tags = {
    Name        = "bastion-LT"
    Environment = var.env
    Owner       = "wordpress-project"
  }
}
resource "aws_autoscaling_group" "bastion_asg" {
  name                = "bastion-asg"
  desired_capacity    = var.ec2-bastion-asg-desired-capacity
  min_size            = var.ec2-bastion-asg-min-capacity
  max_size            = var.ec2-bastion-asg-max-capacity
  vpc_zone_identifier = [aws_subnet.pub-1.id, aws_subnet.pub-2.id]
  launch_template {
    id = aws_launch_template.bastion-LT.id
  }
  tag {
    key                 = "Name"
    value               = "wordpress-project"
    propagate_at_launch = true
  }
}

resource "aws_launch_template" "wordpress" {
  name          = "wordpress-app"
  description   = "Launch Template for the Wordpress instances"
  image_id      = data.aws_ami.amzn_linux.id
  instance_type = var.instance-type-wordpress
  key_name      = var.ec2-public-key-name
  user_data     = base64encode(file("bootstrap.sh"))
  depends_on    = [aws_rds_cluster.wordpress-db-cluster]
  iam_instance_profile {
    name = aws_iam_instance_profile.parameter_store_profile.name
  }
  network_interfaces {
    security_groups = [aws_security_group.wordpress-sg.id]
  }
  tags = {
    Name        = "wordpress-LT"
    Environment = var.env
    Owner       = "wordpress-project"
  }
}
resource "aws_autoscaling_group" "wordpress_asg" {
  name                = "wordpress-asg"
  desired_capacity    = var.ec2-wordpress-asg-desired-capacity
  min_size            = var.ec2-wordpress-asg-min-capacity
  max_size            = var.ec2-wordpress-asg-max-capacity
  vpc_zone_identifier = [aws_subnet.private-app-1.id, aws_subnet.private-app-2.id]
  target_group_arns   = [aws_lb_target_group.alb-tg.arn]
  health_check_type   = "ELB"
  launch_template {
    id = aws_launch_template.wordpress.id
  }
  tag {
    key                 = "Name"
    value               = "wordpress-project"
    propagate_at_launch = true
  }
}

