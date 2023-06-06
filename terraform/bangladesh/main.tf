variable "aws_region" {
  default = "ap-south-1"
}

terraform {
  required_version = "~> 1.1.0"

  backend "s3" {
    bucket         = "simple-server-bangladesh-terraform-state"
    key            = "terraform.tfstate"
    encrypt        = true
    region         = "ap-south-1"
    dynamodb_table = "terraform-lock"
    profile        = "bangladesh"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.9.0"
    }
  }
}

provider "aws" {
  region  = var.aws_region
  profile = "bangladesh"
}

#
# AWS key pair
#
module "simple_aws_key_pair" {
  source = "../modules/simple_aws_key_pair"
}

#
# Networking
#

module "simple_networking" {
  source = "../modules/simple_networking"

  deployment_name   = "bangladesh"
  database_vpc_cidr = "172.32.0.0/16"
  create_alb        = false
  certificate_body  = ""
  certificate_chain = ""
  private_key       = ""
}

#
# s3 for logs
#
variable "s3_logs_bucket_name" {
  type        = string
  description = "Name of s3 bucket to be used for storing logs"
}

module "simple_s3" {
  source      = "../modules/simple_s3"
  bucket_name = var.s3_logs_bucket_name
}

output "s3_user_access_key_id" {
  value = module.simple_s3.user_access_key_id
}

output "s3_user_secret_key" {
  value     = module.simple_s3.user_secret_key
  sensitive = true
}

output "s3_logs_bucket_name" {
  value = var.s3_logs_bucket_name
}
