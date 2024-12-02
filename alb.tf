resource "aws_lb" "wordpress-alb" {
  name                       = "wordpress-lb"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.alb-sg.id]
  subnets                    = [aws_subnet.pub-1.id, aws_subnet.pub-2.id]
  enable_deletion_protection = false

  tags = {
    Environment = var.env
    Owner       = "wordpress-project"
  }
}

output "lb_dns_name" {
  value = aws_lb.wordpress-alb.dns_name
}

resource "aws_lb_target_group" "alb-tg" {
  name        = "wordpress-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.wordpress-vpc.id
  health_check {
    interval            = 30
    path                = "/"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 3
    matcher             = "200"
  }
}

resource "aws_lb_listener" "alb-listener" {
  load_balancer_arn = aws_lb.wordpress-alb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb-tg.arn
  }
}