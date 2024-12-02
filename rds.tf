resource "aws_db_subnet_group" "wordpress-db-subnets" {
  name = "wordpress_db_subnets"
  subnet_ids = [
    aws_subnet.private-data-1.id,
    aws_subnet.private-data-2.id
  ]

  tags = {
    Name        = "WordPress DB subnet group"
    Environment = var.env
  }
}
resource "aws_rds_cluster" "wordpress-db-cluster" {
  cluster_identifier      = "wordpress-cluster"
  engine                  = var.rds-db-engine
  engine_version          = var.rds-db-engine-version
  port                    = var.rds-port
  database_name           = aws_ssm_parameter.db-name.value
  master_username         = aws_ssm_parameter.db-username.value
  master_password         = aws_ssm_parameter.db-password.value
  db_subnet_group_name    = aws_db_subnet_group.wordpress-db-subnets.name
  vpc_security_group_ids  = [aws_security_group.rds-sg.id]
  backup_retention_period = 5
  skip_final_snapshot     = true
}
resource "aws_rds_cluster_instance" "wordpress-cluster-instances" {
  count                = 2
  identifier           = "wordpress-db-instance-${count.index}"
  cluster_identifier   = aws_rds_cluster.wordpress-db-cluster.id
  instance_class       = var.db-instance-type
  engine               = aws_rds_cluster.wordpress-db-cluster.engine
  engine_version       = aws_rds_cluster.wordpress-db-cluster.engine_version
  publicly_accessible  = false
  db_subnet_group_name = aws_db_subnet_group.wordpress-db-subnets.name
}


