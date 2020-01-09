variable "aws_region" {
  default = "ap-south-1"
}

provider "aws" {
  region = var.aws_region
  profile = "bangladesh"

  version = "~> 2.7"
}

terraform { 
  backend "s3" {
    bucket = "simple-bangladesh-terraform-state-2"
    key = "terraform.tfstate"
    encrypt = true
    region = "ap-south-1"
    dynamodb_table = "terraform-lock"
    profile = "bangladesh"
  }
}

variable "bangladesh_database_username" {
  description = "Database Username"
  type        = string
}

variable "bangladesh_database_password" {
  description = "Database Password"
  type        = string
}

module "simple_aws_key_pair" {
  source = "../modules/simple_aws_key_pair"
}

module "simple_networking" {
  source = "../modules/simple_networking"
  deployment_name = "bangladesh"
  database_vpc_cidr = "172.32.0.0/16"
}

module "simple_server_bangladesh_production" {
  source = "../modules/simple_server"
  deployment_name = "bangladesh-production"
  database_vpc_id = module.simple_networking.database_vpc_id
  database_subnet_group_name = module.simple_networking.database_subnet_group_name
  ec2_instance_type = "t2.micro"
  database_username = var.bangladesh_database_username
  database_password = var.bangladesh_database_password
  instance_security_groups = module.simple_networking.instance_security_groups
  aws_key_name = module.simple_aws_key_pair.simple_aws_key_name
  server_vpc_id = module.simple_networking.server_vpc_id
  http_listener_arn = module.simple_networking.http_listener_arn
  host_urls = ["bd.simple.org"]
  create_redis_instance = true
  redis_subnet_group_name = module.simple_networking.redis_subnet_group_name
}
