variable "aws_region" {
  default = "ap-south-1"
}

provider "aws" {
  region  = var.aws_region
  profile = "development"

  version = "~> 2.7"
}

terraform { 
  backend "s3" {
    bucket         = "simple-development-terraform-state"
    key            = "terraform.tfstate"
    encrypt        = true
    region         = "ap-south-1"
    dynamodb_table = "terraform-lock"
    profile        = "development"
  }
}

variable "sandbox_database_username" {
  description = "Database Username"
  type        = string
}

variable "sandbox_database_password" {
  description = "Database Password"
  type        = string
}

variable "qa_database_username" {
  description = "Database Username"
  type        = string
}

variable "qa_database_password" {
  description = "Database Password"
  type        = string
}

module "simple_aws_key_pair" {
  source = "../modules/simple_aws_key_pair"
}

module "simple_networking" {
  source            = "../modules/simple_networking"
  deployment_name   = "development"
  database_vpc_cidr = "172.32.0.0/16"
}

module "simple_redis_param_group" {
  source            = "../modules/simple_redis_param_group"
}

module "simple_server_sandbox" {
  source                     = "../modules/simple_server"
  deployment_name            = "development-sandbox"
  database_vpc_id            = module.simple_networking.database_vpc_id
  database_subnet_group_name = module.simple_networking.database_subnet_group_name
  ec2_instance_type          = "t2.micro"
  database_username          = var.sandbox_database_username
  database_password          = var.sandbox_database_password
  instance_security_groups   = module.simple_networking.instance_security_groups
  aws_key_name               = module.simple_aws_key_pair.simple_aws_key_name
  server_vpc_id              = module.simple_networking.server_vpc_id
  http_listener_arn          = module.simple_networking.http_listener_arn
  host_urls                  = ["api-sandbox.simple.org"]
  create_redis_instance      = true
  redis_param_group_name     = module.simple_redis_param_group.redis_param_group_name
}

module "simple_server_qa" {
  source                     = "../modules/simple_server"
  deployment_name            = "development-qa"
  database_vpc_id            = module.simple_networking.database_vpc_id
  database_subnet_group_name = module.simple_networking.database_subnet_group_name
  ec2_instance_type          = "t2.micro"
  database_username          = var.qa_database_username
  database_password          = var.qa_database_password
  instance_security_groups   = module.simple_networking.instance_security_groups
  aws_key_name               = module.simple_aws_key_pair.simple_aws_key_name
  server_vpc_id              = module.simple_networking.server_vpc_id
  http_listener_arn          = module.simple_networking.http_listener_arn
  host_urls                  = ["api-qa.simple.org"]
  create_redis_instance      = true
  redis_param_group_name     = module.simple_redis_param_group.redis_param_group_name
}
