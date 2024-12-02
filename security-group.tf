####################################################################################
###Bastion Host Security Group & Rules##
####################################################################################
resource "aws_security_group" "bastion-sg" {
  name        = "bastion-sg"
  description = "Bastion instance security groups to open SSH"
  vpc_id      = aws_vpc.wordpress-vpc.id
  tags = {
    Name        = "wordpress"
    Environment = var.env
  }
}
resource "aws_vpc_security_group_ingress_rule" "ssh-inbound" {
  security_group_id = aws_security_group.bastion-sg.id
  cidr_ipv4         = var.ssh-myip
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}
resource "aws_vpc_security_group_egress_rule" "ssh-outbound" {
  security_group_id = aws_security_group.bastion-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

####################################################################################
##Application LoadBalancer Security Group & Rules##
####################################################################################

resource "aws_security_group" "alb-sg" {
  name        = "ALB"
  description = "application load balncer security group to open public http"
  vpc_id      = aws_vpc.wordpress-vpc.id
  tags = {
    Name        = "wordpress"
    Environment = var.env
  }
}
resource "aws_vpc_security_group_ingress_rule" "http-inbound" {
  security_group_id = aws_security_group.alb-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
}
resource "aws_vpc_security_group_egress_rule" "http-outbound" {
  security_group_id = aws_security_group.alb-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

####################################################################################
##Wordpress Security Group & Rules##
####################################################################################

resource "aws_security_group" "wordpress-sg" {
  name        = "wordpress-sg"
  description = "application security group"
  vpc_id      = aws_vpc.wordpress-vpc.id
  tags = {
    Name        = "wordpress"
    Environment = var.env
  }
}
resource "aws_vpc_security_group_ingress_rule" "wordpress-alb-inbound" {
  security_group_id            = aws_security_group.wordpress-sg.id
  referenced_security_group_id = aws_security_group.alb-sg.id
  from_port                    = 80
  to_port                      = 80
  ip_protocol                  = "tcp"
}
resource "aws_vpc_security_group_ingress_rule" "wordpress-rds-inbound" {
  security_group_id            = aws_security_group.wordpress-sg.id
  referenced_security_group_id = aws_security_group.rds-sg.id
  from_port                    = var.rds-port
  to_port                      = var.rds-port
  ip_protocol                  = "tcp"
}
resource "aws_vpc_security_group_ingress_rule" "wordpress-memcached-inbound" {
  security_group_id            = aws_security_group.wordpress-sg.id
  referenced_security_group_id = aws_security_group.memcached-sg.id
  from_port                    = var.ec-memcached-port
  to_port                      = var.ec-memcached-port
  ip_protocol                  = "tcp"
}
resource "aws_vpc_security_group_ingress_rule" "wordpress-efs-inbound" {
  security_group_id            = aws_security_group.wordpress-sg.id
  referenced_security_group_id = aws_security_group.efs-sg.id
  from_port                    = 2049
  to_port                      = 2049
  ip_protocol                  = "tcp"
}
resource "aws_vpc_security_group_ingress_rule" "wordpress-bastion-inbound" {
  security_group_id            = aws_security_group.wordpress-sg.id
  referenced_security_group_id = aws_security_group.bastion-sg.id
  from_port                    = 22
  to_port                      = 22
  ip_protocol                  = "tcp"
}
resource "aws_vpc_security_group_egress_rule" "wordpress-outbound" {
  security_group_id = aws_security_group.wordpress-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

####################################################################################
##RDS Security Group##
####################################################################################

resource "aws_security_group" "rds-sg" {
  name        = "rds-sg"
  description = "Open MySQL port 3306 for EC2 instances"
  vpc_id      = aws_vpc.wordpress-vpc.id
  tags = {
    Name        = "wordpress"
    Environment = var.env
  }
}
resource "aws_vpc_security_group_ingress_rule" "rds-inbound" {
  security_group_id            = aws_security_group.rds-sg.id
  referenced_security_group_id = aws_security_group.wordpress-sg.id
  from_port                    = var.rds-port
  to_port                      = var.rds-port
  ip_protocol                  = "tcp"
}
resource "aws_vpc_security_group_egress_rule" "rds-outbound" {
  security_group_id = aws_security_group.rds-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}
####################################################################################
##Memcached Security Group##
####################################################################################

resource "aws_security_group" "memcached-sg" {
  name        = "memcached-sg"
  description = "Opening memcached port for wordpress autoscaling group security group"
  vpc_id      = aws_vpc.wordpress-vpc.id
  tags = {
    Name        = "wordpress"
    Environment = var.env
  }
}
resource "aws_vpc_security_group_ingress_rule" "memcached-inbound" {
  security_group_id            = aws_security_group.memcached-sg.id
  referenced_security_group_id = aws_security_group.wordpress-sg.id
  from_port                    = var.ec-memcached-port
  to_port                      = var.ec-memcached-port
  ip_protocol                  = "tcp"
}
resource "aws_vpc_security_group_egress_rule" "memcached-outbound" {
  security_group_id = aws_security_group.memcached-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

####################################################################################
##EFS Security Group##
####################################################################################

resource "aws_security_group" "efs-sg" {
  name        = "efs_sg"
  description = "Opening EFS mount target port"
  vpc_id      = aws_vpc.wordpress-vpc.id
  tags = {
    Name        = "wordpress"
    Environment = var.env
  }
}
resource "aws_vpc_security_group_ingress_rule" "efs-inbound" {
  security_group_id            = aws_security_group.efs-sg.id
  referenced_security_group_id = aws_security_group.wordpress-sg.id
  from_port                    = 2049
  to_port                      = 2049
  ip_protocol                  = "tcp"
}
resource "aws_vpc_security_group_egress_rule" "efs-outbound" {
  security_group_id = aws_security_group.efs-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}





