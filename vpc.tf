####################################################################################
###VPC###
####################################################################################

resource "aws_vpc" "wordpress-vpc" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  tags = {
    Name        = "wordpress-vpc"
    Environment = var.env
    Owner       = "wordpress-project"
  }
}
####################################################################################
###Subnets###
####################################################################################

data "aws_availability_zones" "azs" {
  state = "available"
}
locals {
  azs = data.aws_availability_zones.azs.names
}

resource "aws_subnet" "pub-1" {
  vpc_id            = aws_vpc.wordpress-vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = local.azs[0]
  tags = {
    Name        = "pub-1"
    Environment = var.env
    Owner       = "wordpress-project"
  }
}
resource "aws_subnet" "pub-2" {
  vpc_id            = aws_vpc.wordpress-vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = local.azs[1]
  tags = {
    Name        = "pub-2"
    Environment = var.env
    Owner       = "wordpress-project"
  }
}

resource "aws_subnet" "private-app-1" {
  vpc_id            = aws_vpc.wordpress-vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = local.azs[0]
  tags = {
    Name        = "private-app-1"
    Environment = var.env
    Owner       = "wordpress-project"
  }
}
resource "aws_subnet" "private-app-2" {
  vpc_id            = aws_vpc.wordpress-vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = local.azs[1]
  tags = {
    Name        = "private-app-2"
    Environment = var.env
    Owner       = "wordpress-project"
  }
}

resource "aws_subnet" "private-data-1" {
  vpc_id            = aws_vpc.wordpress-vpc.id
  cidr_block        = "10.0.5.0/24"
  availability_zone = local.azs[0]
  tags = {
    Name        = "private-data-1"
    Environment = var.env
    Owner       = "wordpress-project"
  }
}
resource "aws_subnet" "private-data-2" {
  vpc_id            = aws_vpc.wordpress-vpc.id
  cidr_block        = "10.0.6.0/24"
  availability_zone = local.azs[1]
  tags = {
    Name        = "private-data-2"
    Environment = var.env
    Owner       = "wordpress-project"
  }
}

####################################################################################
###Internet Gateway###
####################################################################################

resource "aws_internet_gateway" "wordpress-IGW" {
  vpc_id = aws_vpc.wordpress-vpc.id
  tags = {
    Name        = "wordpress-IGW"
    Environment = var.env
    Owner       = "wordpress-project"
  }
}

####################################################################################
###EIP###
####################################################################################

resource "aws_eip" "eip" {
  domain     = "vpc"
  count      = 2
  depends_on = [aws_internet_gateway.wordpress-IGW]
}

####################################################################################
###Nat Gateway###
####################################################################################

resource "aws_nat_gateway" "wordpress-NAT-1" {
  allocation_id = aws_eip.eip[0].id
  subnet_id     = aws_subnet.pub-1.id
  depends_on = [ aws_eip.eip ]
  tags = {
    Name        = "wordpress-NATGW"
    Environment = var.env
    Owner       = "wordpress-project"
  }
}
resource "aws_nat_gateway" "wordpress-NAT-2" {
  allocation_id = aws_eip.eip[1].id
  subnet_id     = aws_subnet.pub-2.id
  depends_on = [ aws_eip.eip ]

  tags = {
    Name        = "wordpress-NATGW"
    Environment = var.env
    Owner       = "wordpress-project"
  }
}

####################################################################################
###Route Tables####
####################################################################################

resource "aws_route_table" "pub-RT" {
  vpc_id = aws_vpc.wordpress-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.wordpress-IGW.id
  }
  tags = {
    Name        = "pub-RT"
    Environment = var.env
    Owner       = "wordpress-project"
  }
}
resource "aws_route_table" "private-RT-1" {
  vpc_id = aws_vpc.wordpress-vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.wordpress-NAT-1.id

  }
}
resource "aws_route_table" "private-RT-2" {
  vpc_id = aws_vpc.wordpress-vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.wordpress-NAT-2.id

  }
}
resource "aws_route_table_association" "pub-1" {
  subnet_id      = aws_subnet.pub-1.id
  route_table_id = aws_route_table.pub-RT.id
}
resource "aws_route_table_association" "pub-2" {
  subnet_id      = aws_subnet.pub-2.id
  route_table_id = aws_route_table.pub-RT.id
}
resource "aws_route_table_association" "private-1" {
  subnet_id      = aws_subnet.private-app-1.id
  route_table_id = aws_route_table.private-RT-1.id
}
resource "aws_route_table_association" "private-2" {
  subnet_id      = aws_subnet.private-app-2.id
  route_table_id = aws_route_table.private-RT-2.id
}
####################################################################################


