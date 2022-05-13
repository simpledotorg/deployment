variable "aws_region" {
  default = "ap-south-1"
}

terraform {
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
      source = "hashicorp/aws"
      version = "~> 4.9.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
  profile = "bangladesh"
}

#
# Database username and passwords
#
variable "bangladesh_database_username" {
  description = "Database Username"
  type        = string
}

variable "bangladesh_database_password" {
  description = "Database Password"
  type        = string
}

variable "bangladesh_staging_database_username" {
  description = "Database Username"
  type        = string
}

variable "bangladesh_staging_database_password" {
  description = "Database Password"
  type        = string
}


#
# SSL Certificate files for domain
#

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
# AWS key pair
#
module "simple_aws_key_pair" {
  source = "../modules/simple_aws_key_pair"
}

#
# Networking
#

module "simple_networking" {
  source            = "../modules/simple_networking"

  deployment_name   = "bangladesh"
  database_vpc_cidr = "172.32.0.0/16"
  certificate_body  = file(var.certificate_body_file)
  certificate_chain = file(var.certificate_chain_file)
  private_key       = file(var.certificate_private_key_file)
}

#
# redis
#
module "simple_redis_param_group" {
  source = "../modules/simple_redis_param_group"
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
module "simple_server_bangladesh_production" {
  source                        = "../modules/simple_server"
  deployment_name               = "bangladesh-production"
  database_vpc_id               = module.simple_networking.database_vpc_id
  database_subnet_group_name    = module.simple_networking.database_subnet_group_name
  ec2_instance_type             = "t3.xlarge"
  ec2_ubuntu_version            = "20.04"
  database_username             = var.bangladesh_database_username
  database_password             = var.bangladesh_database_password
  instance_security_groups      = module.simple_networking.instance_security_groups
  aws_key_name                  = module.simple_aws_key_pair.simple_aws_key_name
  server_vpc_id                 = module.simple_networking.server_vpc_id
  https_listener_arn            = module.simple_networking.https_listener_arn
  load_balancer_arn_suffix      = module.simple_networking.load_balancer_arn_suffix
  host_urls                     = ["bd.simple.org", "api.bd.simple.org", "dashboard.bd.simple.org"]
  create_redis_cache_instance   = true
  create_redis_sidekiq_instance = true
  create_database_replica       = true
  server_count                  = 2
  sidekiq_server_count          = 1
  redis_param_group_name        = module.simple_redis_param_group.redis_param_group_name
  enable_cloudwatch_alerts      = true
  cloudwatch_alerts_sns_arn     = module.notify_slack.this_slack_topic_arn
}

module "simple_server_bangladesh_staging" {
  source                        = "../modules/simple_server"
  deployment_name               = "bangladesh-staging"
  database_vpc_id               = module.simple_networking.database_vpc_id
  database_subnet_group_name    = module.simple_networking.database_subnet_group_name
  ec2_instance_type             = "t2.medium"
  ec2_ubuntu_version            = "20.04"
  database_username             = var.bangladesh_staging_database_username
  database_password             = var.bangladesh_staging_database_password
  instance_security_groups      = module.simple_networking.instance_security_groups
  aws_key_name                  = module.simple_aws_key_pair.simple_aws_key_name
  server_vpc_id                 = module.simple_networking.server_vpc_id
  https_listener_arn            = module.simple_networking.https_listener_arn
  load_balancer_arn_suffix      = module.simple_networking.load_balancer_arn_suffix
  host_urls                     = ["api-demo.bd.simple.org", "api-staging.bd.simple.org", "dashboard-demo.bd.simple.org", "dashboard-staging.bd.simple.org"]
  create_redis_cache_instance   = true
  create_redis_sidekiq_instance = true
  create_database_replica       = true
  server_count                  = 1
  sidekiq_server_count          = 1
  redis_param_group_name        = module.simple_redis_param_group.redis_param_group_name
  enable_cloudwatch_alerts      = true
  cloudwatch_alerts_sns_arn     = module.notify_slack.this_slack_topic_arn
}
