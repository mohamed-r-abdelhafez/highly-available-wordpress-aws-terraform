terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "2.3.0"
    }
  }
}


provider "aws" {
  region = var.region

}
provider "random" {
  # Configuration options
}