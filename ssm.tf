
###########################################################
#Generate Random username and password#
###########################################################
resource "random_string" "username" {
  length  = 12
  special = false
  upper   = false
  number  = false
}
resource "random_password" "password" {
  length           = 12
  special          = false
  upper            = true
  number           = true
  override_special = "_-"
}
###########################################################
#Storing all credentials as a System Manager Parameter Store parameters#
###########################################################
resource "aws_ssm_parameter" "db-name" {
  name        = "/db-server/db-name"
  description = "Database name for wordpress"
  type        = "String"
  value       = "wordpressdb"
}
resource "aws_ssm_parameter" "db-username" {
  name        = "/db-server/db-username"
  description = "Database username to be created in $db_name database"
  type        = "String"
  value       = random_string.username.result
}
output "username" {
  value     = aws_ssm_parameter.db-username.value
  sensitive = true
}
resource "aws_ssm_parameter" "db-password" {
  name        = "/db-server/password"
  description = "Database password for $db_username"
  type        = "SecureString"
  value       = random_password.password.result
}

resource "aws_ssm_parameter" "db-host" {
  name        = "/db-server/db-host"
  description = "Database Endpoint"
  type        = "String"
  value       = aws_rds_cluster.wordpress-db-cluster.endpoint
}

resource "aws_ssm_parameter" "wp-title" {
  name        = "/wordpress/title"
  description = "Wordpress website title"
  type        = "String"
  value       = "The Coolest Wordpress Site"
}

resource "aws_ssm_parameter" "wp-username" {
  name        = "/wordpress/username"
  description = "WordPress Admin username"
  type        = "String"
  value       = random_string.username.result
}

resource "aws_ssm_parameter" "wp-password" {
  name        = "/wordpress/password"
  description = "WordPress Admin password"
  type        = "SecureString"
  value       = random_password.password.result
}

resource "aws_ssm_parameter" "wp-email" {
  name        = "/wordpress/email"
  description = "WordPress Admin email"
  type        = "String"
  value       = var.wp-admin-email
}

resource "aws_ssm_parameter" "site-url" {
  name        = "/wordpress/site_url"
  description = "WordPress site url"
  type        = "String"
  value       = format("http://%s", aws_lb.wordpress-alb.dns_name)
}

###########################################################
#memcached Endpoint#
###########################################################
resource "aws_ssm_parameter" "memcached-endpoint" {
  name        = "/memcached/endpoint"
  description = "memcached cluster endpoint"
  type        = "String"
  value       = aws_elasticache_cluster.memcached-cluster.configuration_endpoint

}
resource "aws_ssm_parameter" "memcached-port" {
  name        = "/memcached/port"
  description = "memcached cluster port"
  type        = "String"
  value       = "11211"
}

###########################################################
#EFS ID#
###########################################################
resource "aws_ssm_parameter" "efs-id" {
  name        = "/efs/id"
  description = "id of EFS to mount"
  type        = "String"
  value       = aws_efs_file_system.wordpress-fs.id
}