variable "aws_region" {
  default = "ap-south-1"
}

terraform {
  backend "s3" {
    bucket         = "simple-server-development-terraform-state"
    key            = "terraform.tfstate"
    encrypt        = true
    region         = "ap-south-1"
    dynamodb_table = "terraform-lock"
    profile        = "development"
  }

  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 4.9.0"
    }
  }
}

provider "aws" {
  region  = var.aws_region
  profile = "development"
}


#
# database u/p vars
#
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

variable "security_database_username" {
  description = "Database Username"
  type        = string
}

variable "security_database_password" {
  description = "Database Password"
  type        = string
}

#
# certficate stuff
#
variable "certificate_body_file" {
  description = "certificate for domain name"
}

variable "certificate_chain_file" {
  description = "certificate chain for domain name"
}

variable "certificate_private_key_file" {
  description = "Key to private key in ssl vault"
  type        = string
}

#
# slack credentials for cloudwatch
#
variable "slack_webhook_url" {
	description = "Slack webhook URL for creating AWS SNS topic"
	type        = string
}

variable "slack_channel" {
	description = "Slack channel name to which notifications are sent"
	type        = string
}

variable "slack_username" {
	description = "Slack username to user for sending notifications"
	type        = string
}

#
# aws key pair
#
module "simple_aws_key_pair" {
  source = "../modules/simple_aws_key_pair"
}

#
# redis
#
module "simple_redis_param_group" {
  source            = "../modules/simple_redis_param_group"
}

#
# networking
#
module "simple_networking" {
  source            = "../modules/simple_networking"

  deployment_name   = "development"
  database_vpc_cidr = "172.32.0.0/16"
  certificate_body  = file(var.certificate_body_file)
  certificate_chain = file(var.certificate_chain_file)
  private_key       = file(var.certificate_private_key_file)
}

#
# slack alerts lambda
#
module "notify_slack" {
  source  = "terraform-aws-modules/notify-slack/aws"
  version = "5.0.0"

  sns_topic_name       = "cloudwatch-to-slack"
  slack_webhook_url    = var.slack_webhook_url
  slack_channel        = var.slack_channel
  slack_username       = var.slack_username

  lambda_function_name = "cloudwatch-to-slack"
}

#
# server configs
#
module "simple_server_sandbox" {
  source                        = "../modules/simple_server"
  deployment_name               = "development-sandbox"
  database_vpc_id               = module.simple_networking.database_vpc_id
  database_subnet_group_name    = module.simple_networking.database_subnet_group_name
  ec2_instance_type             = "t2.2xlarge"
  ec2_ubuntu_version            = "20.04"
  database_instance_type        = "db.r4.xlarge"
  server_count                  = 1
  sidekiq_server_count          = 1
  database_username             = var.sandbox_database_username
  database_password             = var.sandbox_database_password
  instance_security_groups      = module.simple_networking.instance_security_groups
  aws_key_name                  = module.simple_aws_key_pair.simple_aws_key_name
  server_vpc_id                 = module.simple_networking.server_vpc_id
  https_listener_arn            = module.simple_networking.https_listener_arn
  load_balancer_arn_suffix      = module.simple_networking.load_balancer_arn_suffix
  host_urls                     = ["api-sandbox.simple.org", "dashboard-sandbox.simple.org"]
  create_redis_cache_instance   = true
  create_redis_sidekiq_instance = true
  redis_param_group_name        = module.simple_redis_param_group.redis_param_group_name
  enable_cloudwatch_alerts      = true
  cloudwatch_alerts_sns_arn     = module.notify_slack.this_slack_topic_arn
}

module "simple_server_qa" {
  source                        = "../modules/simple_server"
  deployment_name               = "development-qa"
  database_vpc_id               = module.simple_networking.database_vpc_id
  database_subnet_group_name    = module.simple_networking.database_subnet_group_name
  ec2_instance_type             = "t2.large"
  ec2_ubuntu_version            = "20.04"
  database_username             = var.qa_database_username
  database_password             = var.qa_database_password
  instance_security_groups      = module.simple_networking.instance_security_groups
  aws_key_name                  = module.simple_aws_key_pair.simple_aws_key_name
  server_vpc_id                 = module.simple_networking.server_vpc_id
  https_listener_arn            = module.simple_networking.https_listener_arn
  load_balancer_arn_suffix      = module.simple_networking.load_balancer_arn_suffix
  host_urls                     = ["api-qa.simple.org", "dashboard-qa.simple.org"]
  create_redis_cache_instance   = true
  create_redis_sidekiq_instance = true
  redis_param_group_name        = module.simple_redis_param_group.redis_param_group_name
  enable_cloudwatch_alerts      = true
  cloudwatch_alerts_sns_arn     = module.notify_slack.this_slack_topic_arn
}

module "simple_server_security" {
  source                        = "../modules/simple_server"
  deployment_name               = "development-security"
  database_vpc_id               = module.simple_networking.database_vpc_id
  database_subnet_group_name    = module.simple_networking.database_subnet_group_name
  ec2_instance_type             = "t2.large"
  ec2_ubuntu_version            = "20.04"
  database_username             = var.security_database_username
  database_password             = var.security_database_password
  instance_security_groups      = module.simple_networking.instance_security_groups
  aws_key_name                  = module.simple_aws_key_pair.simple_aws_key_name
  server_vpc_id                 = module.simple_networking.server_vpc_id
  https_listener_arn            = module.simple_networking.https_listener_arn
  load_balancer_arn_suffix      = module.simple_networking.load_balancer_arn_suffix
  host_urls                     = ["api-security.simple.org", "dashboard-security.simple.org"]
  create_redis_cache_instance   = true
  create_redis_sidekiq_instance = true
  redis_param_group_name        = module.simple_redis_param_group.redis_param_group_name
  enable_cloudwatch_alerts      = false
  cloudwatch_alerts_sns_arn     = module.notify_slack.this_slack_topic_arn
}

/* This sets up a bunch of ec2 servers for the standalone setup
   with the appropriate security groups.

module "simple_server_playground" {
  source                     = "../modules/simple_server_standalone"
  deployment_name            = "development-playground"
  ec2_instance_type          = "t2.micro"
  instance_security_groups   = module.simple_networking.standalone_instance_security_groups
  aws_key_name               = module.simple_aws_key_pair.simple_aws_key_name
  server_vpc_id              = module.simple_networking.server_vpc_id
  https_listener_arn         = module.simple_networking.https_listener_arn
  host_urls                  = ["api-playground.simple.org", "dashboard-playground.simple.org"]
  app_server_count           = 1
  sidekiq_server_count       = 1
  database_server_count      = 2
  redis_server_count         = 1
  monitoring_server_count    = 1
  storage_server_count       = 1
} */
