variable "aws_region" {
  default = "ap-south-1"
}

terraform {
  required_version = "~> 1.1.0"

  backend "s3" {
    bucket         = "simple-server-india-terraform-state"
    key            = "terraform.tfstate"
    encrypt        = true
    region         = "ap-south-1"
    dynamodb_table = "terraform-lock"
    profile        = "india"
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
  profile = "india"
}

#
# Database username and passwords
#
variable "production_database_username" {
  description = "Database Username"
  type        = string
}

variable "production_database_password" {
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

variable "additional_certificates" {
  description = "Additional certificates"
  type = list(object({
    body_file        = string
    chain_file       = string
    private_key_file = string
  }))
  default = []
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
  source = "../modules/simple_networking"

  deployment_name         = "india"
  database_vpc_cidr       = "172.32.0.0/16"
  certificate_body        = file(var.certificate_body_file)
  certificate_chain       = file(var.certificate_chain_file)
  private_key             = file(var.certificate_private_key_file)
  additional_certificates = var.additional_certificates
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

  sns_topic_name    = "cloudwatch-to-slack"
  slack_webhook_url = var.slack_webhook_url
  slack_channel     = var.slack_channel
  slack_username    = var.slack_username

  lambda_function_name = "cloudwatch-to-slack"
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

#
# server configs
#
module "simple_server_india_production" {
  source                                   = "../modules/simple_server"
  deployment_name                          = "india-production"
  database_postgres_version                = "14.6"
  database_custom_param_group              = true
  database_max_parallel_workers_per_gather = 4
  database_random_page_cost                = 1
  database_work_mem                        = 30000
  database_vpc_id                          = module.simple_networking.database_vpc_id
  database_subnet_group_name               = module.simple_networking.database_subnet_group_name
  ec2_instance_type                        = "t3.xlarge"
  ec2_ubuntu_version                       = "20.04"
  ec2_volume_size                          = "100"
  database_instance_type                   = "db.m5.4xlarge"
  database_replica_instance_type           = "db.m5.2xlarge"
  database_allocated_storage               = "1000"
  database_username                        = var.production_database_username
  database_password                        = var.production_database_password
  instance_security_groups                 = module.simple_networking.instance_security_groups
  aws_key_name                             = module.simple_aws_key_pair.simple_aws_key_name
  server_vpc_id                            = module.simple_networking.server_vpc_id
  https_listener_arn                       = module.simple_networking.https_listener_arn
  load_balancer_arn_suffix                 = module.simple_networking.load_balancer_arn_suffix
  host_urls                                = ["api.in.simple.org", "dashboard.in.simple.org", "api.simple.org", "dashboard.simple.org"]
  create_redis_cache_instance              = true
  create_redis_sidekiq_instance            = true
  redis_node_type                          = "cache.r5.large"
  create_database_replica                  = true
  server_count                             = 5
  sidekiq_server_count                     = 2
  redis_param_group_name                   = module.simple_redis_param_group.redis_param_group_name
  enable_cloudwatch_alerts                 = true
  cloudwatch_alerts_sns_arn                = module.notify_slack.this_slack_topic_arn
  redis_version                            = "5.0.6"
}

output "simple_server_india_production_server_instance_ips" {
  value = module.simple_server_india_production.server_instance_ips
}

output "simple_server_india_production_sidekiq_instance_ips" {
  value = module.simple_server_india_production.sidekiq_instance_ips
}

output "simple_server_india_production_database_url" {
  value = module.simple_server_india_production.database_url
}

output "simple_server_india_production_cache_redis_url" {
  value = module.simple_server_india_production.cache_redis_url
}

output "simple_server_india_production_sidekiq_redis_url" {
  value = module.simple_server_india_production.sidekiq_redis_url
}

output "simple_server_india_staging_load_balancer_public_dns" {
  value = module.simple_networking.load_balancer_public_dns
}
