resource "aws_efs_file_system" "wordpress-fs" {
  creation_token   = "wordpress-file-system"
  performance_mode = "generalPurpose"

  lifecycle_policy {
    transition_to_ia = "AFTER_60_DAYS"
  }
  tags = {
    Name        = "wordpress"
    Environment = var.env
  }
}

resource "aws_efs_mount_target" "wordpress_mount_target-1" {
  file_system_id  = aws_efs_file_system.wordpress-fs.id
  subnet_id       = aws_subnet.private-data-1.id
  security_groups = [aws_security_group.efs-sg.id]
}
resource "aws_efs_mount_target" "wordpress_mount_target-2" {
  file_system_id  = aws_efs_file_system.wordpress-fs.id
  subnet_id       = aws_subnet.private-data-2.id
  security_groups = [aws_security_group.efs-sg.id]
}