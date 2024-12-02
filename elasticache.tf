resource "aws_elasticache_subnet_group" "memcached-subnet-group" {
  name = "memcached-subnet-group"
  subnet_ids = [
    aws_subnet.private-data-1.id,
    aws_subnet.private-data-2.id
  ]
  tags = {
    Name        = "WordPress ElastiCache subnet group"
    Environment = var.env
  }
}

resource "aws_elasticache_cluster" "memcached-cluster" {
  cluster_id         = "wordpress-cluster"
  engine             = "memcached"
  node_type          = var.ec-node-type
  num_cache_nodes    = var.ec-nodes-count
  az_mode            = var.ec-az-mode
  port               = var.ec-memcached-port
  subnet_group_name  = aws_elasticache_subnet_group.memcached-subnet-group.name
  security_group_ids = [aws_security_group.memcached-sg.id]
}