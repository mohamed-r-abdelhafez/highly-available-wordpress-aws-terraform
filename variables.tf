####################################################################################
##region##
####################################################################################

variable "region" {
  type        = string
  description = "current region to deploy"
}
####################################################################################
##env##
####################################################################################

variable "env" {
  type        = string
  description = "current enviroment pod, dev etc.."
}
####################################################################################
##security group##
####################################################################################

variable "ssh-myip" {
  type        = string
  description = "allowing ssh to bastion host from my ip "
}
####################################################################################
##EC2##
####################################################################################

variable "instance-type-bs" {
  type = string
}
variable "instance-type-wordpress" {
  type = string
}
variable "ec2-public-key-name" {
  type        = string
  description = "SSH public key name for the AWS key pair"
}

variable "ec2-public-key-path" {
  type        = string
  description = "The path on the local machine for the SSH public key"
}

variable "ec2-bastion-asg-desired-capacity" {
  type        = number
  description = "desired capacity for bastion host autoscaling group"
}
variable "ec2-bastion-asg-min-capacity" {
  type        = number
  description = "minimum capacity for bastion host autoscaling group"
}
variable "ec2-bastion-asg-max-capacity" {
  type        = number
  description = "maximum capacity for bastion host autoscaling group"
}
variable "ec2-wordpress-asg-desired-capacity" {
  type        = number
  description = "desired capacity for wordpress autoscaling group"
}
variable "ec2-wordpress-asg-min-capacity" {
  type        = number
  description = "desired capacity for wordpress autoscaling group"
}
variable "ec2-wordpress-asg-max-capacity" {
  type        = number
  description = "desired capacity for wordpress autoscaling group"
}

####################################################################################
##RDS###
####################################################################################

variable "rds-port" {
  type        = number
  description = "The port that the DB engine listening on"
}
variable "rds-db-engine" {
  type        = string
  description = "The type of engine to run on the DB instance aurora, mysql, postgresql, etc.."
}
variable "rds-db-engine-version" {
  type        = string
  description = "The version of the engine running on the DB instance"
}
variable "db-instance-type" {
  type        = string
  description = "The DB instance class type db.t2.micro, db.m5.larage, etc.."
}


####################################################################################
##Elastic Cache###
####################################################################################

variable "ec-memcached-port" {
  type        = number
  description = "The Memcache port that the nodes will be listing on"
}
variable "ec-node-type" {
  type        = string
  description = "The instance type for each node in the cluster"
}
variable "ec-nodes-count" {
  type        = number
  description = "Number of nodes in the cluster if az_mode is cross-az this must be more than 1"
}
variable "ec-az-mode" {
  type        = string
  description = "Specifies whether the nodes is going to be created across azs or in a single az"
  validation {
    condition     = var.ec-az-mode == "cross-az" || var.ec-az-mode == "single-az"
    error_message = "The az_mode value can only be 'cross-az' or 'single-az'."
  }
}
####################################################################################
##Wordpress###
####################################################################################

variable "wp-admin-email" {
  type        = string
  description = "Wordpress Admin email address"
}

