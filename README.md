# Hosting Highly Available Wordpress on AWS using Terraform 
This project takes inspiration from AWS Whitepaper [Best Practices for WordPress on AWS](https://docs.aws.amazon.com/whitepapers/latest/best-practices-wordpress/reference-architecture.html) , This project automates the deployment of a high-availability WordPress site on AWS using Terraform. It includes components for scalability, security, and performance optimization. This setup ensures your WordPress site is resilient, highly available, and optimized for production workloads.
# Architecture
![AWS Architecture](https://github.com/mohamed-r-abdelhafez/highly-available-wordpress-aws-terraform/blob/main/WordPress%20Architecture.png)
# Prerequisites
1- **Terraform** installed on your local machine , if you dont have it you can [Download it](https://developer.hashicorp.com/terraform/install) 

2- **AWS CLI** installed and configured with appropriate credential to allow Terraform to manage AWS resources [Download and Install here](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)

`aws configure`

3- **Domain Name**

# Components
**Networking**
* VPC.
* Subnets 6 in 2 availablity zones ( 2 public / 2 private for application / 2 private for data ).
* Internet Gateway.
* NAT Gateway.
* 2 Elastic IP attached to Nat Gatway on public subnets.
* Public route tables direct public trrafic to IGW and private route table direct trrafic from application subnets to NAT .

**Security**
* IAM rules to allow ec2 to accessing AWS resources without hard coding any credentials.
* AWS SSM Parameter store to store sensitive credentials and configuration endpoints.
* Security Groups restrict access to AWS resources by using Security Groups Chaining method to form a chain of security groups to enhancing security while simplifying management.

**Application**
* ALB to distribute traffic to Wordpress Instances and health check for instances.
* Auto Scaling for bastion host instance to ensure availability and securly SSH to Wordpress instances.
* Auto scaling for Wordpress Instances to ensure scalability and high availability.
* Bootstrap script as ec2 user data to install necessary packages, wordpress, memcached clint and w3-total cache plugin, mount efs file system, Fetching credentials and configuration endpoints from SSM Parameter Store and configure nginx.

**Data**
* RDS Aurora Cluster with two instances, one per availability zone.
* Elasticache Memcached Cluster Multi AZ mode
* EFS file system with 2 targets mount in both availablility zone.
* S3 Bucket for static content and bucket policy with appropriate permision to allow access only from CloudFront

**DNS&CDN**
* CloudFront for content delivery to reduce letancy, cost optimization and improve security,with 2 origins ALB for dynamic content and S3 for static content with Origin access control (OAC) to secures S3 origin access to CloudFront only.
* Route53 for DNS resolution with hosted zone and record alise refeer to CloudFront doman name.

**Contributing**
If you find anything here that needs fixing, or if you have improvements, please fork, fix and submit a pull request, or drop me a line if you have any questions. Thanks



