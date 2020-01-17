variable "aws_region" {
  default = "ap-south-1"
}

provider "aws" {
  region  = var.aws_region
  profile = "bangladesh"

  version = "~> 2.7"
}

terraform { 
  backend "s3" {
    bucket         = "simple-bangladesh-terraform-state-2"
    key            = "terraform.tfstate"
    encrypt        = true
    region         = "ap-south-1"
    dynamodb_table = "terraform-lock"
    profile        = "bangladesh"
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

variable "certificate_body_file" {
  description = "certificate for domain name"
  type        = string
}

variable "certificate_chain_file" {
  description = "certificate chain for domain name"
  type        = string
}

variable "certificate_private_key_file" {
  description = "Key to private key in ssl vault"
  type        = string
}

module "simple_aws_key_pair" {
  source = "../modules/simple_aws_key_pair"
}

module "simple_networking" {
  source            = "../modules/simple_networking"

  deployment_name   = "bangladesh"
  database_vpc_cidr = "172.32.0.0/16"
  certificate_body  = file(var.certificate_body_file)
  certificate_chain = file(var.certificate_chain_file)
  private_key       = file(var.certificate_private_key_file)
}

module "simple_redis_param_group" {
  source = "../modules/simple_redis_param_group"
}

module "simple_server_bangladesh_production" {
  source                     = "../modules/simple_server"
  deployment_name            = "bangladesh-production"
  database_vpc_id            = module.simple_networking.database_vpc_id
  database_subnet_group_name = module.simple_networking.database_subnet_group_name
  ec2_instance_type          = "t2.micro"
  database_username          = var.bangladesh_database_username
  database_password          = var.bangladesh_database_password
  instance_security_groups   = module.simple_networking.instance_security_groups
  aws_key_name               = module.simple_aws_key_pair.simple_aws_key_name
  server_vpc_id              = module.simple_networking.server_vpc_id
  https_listener_arn         = module.simple_networking.https_listener_arn
  host_urls                  = ["bd.simple.org"]
  create_redis_instance      = true
  create_database_replica    = true
  redis_param_group_name     = module.simple_redis_param_group.redis_param_group_name
}
