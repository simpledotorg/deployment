variable "deployment_name" {
  description = "The name of the deployment"
  type        = string
}

variable "ec2_instance_type" {
  description = "The type of instance for ec2 servers"
  type        = string
}

variable "server_count" {
  description = "The number of instance for ec2 servers"
  type        = number
  default     = 1
}

variable "database_username" {
  description = "Database Username"
  type        = string
}

variable "database_password" {
  description = "Database Password"
  type        = string
}

variable "database_vpc_id" {
  description = "Database vpc-id"
  type        = string
}

variable "database_subnet_group_name" {
  description = "Database vpc-id"
  type        = string
}

variable "instance_security_groups" {
  description = "Security groups assigned to instance"
  type        = list(string)
}

variable "aws_key_name" { 
  description = "Name of the default aws key"
  type        = string
}

variable  "server_vpc_id" {
  description = "Server vpc-id"
  type        = string
}

variable "https_listener_arn" {
  description = "HTTPS listener arn"
  type        = string
}

variable "load_balancer_arn_suffix" {
  description = "Load balancer arn"
  type        = string
  default     = ""
}

variable "host_urls" {
  description = "List of host URL"
  type        = list(string)
}

variable "create_redis_instance" {
  description = "Create an additional redis instance"
  type        = bool
  default     = false
}

variable "redis_subnet_group_name" {
  description = "Name of the redis subnet"
  type        = string
  default     = ""
}

variable "create_database_replica" {
  description = "Create an additional redis instance"
  type        = bool
  default     = false
}

variable "redis_param_group_name" {
  description = "Name of the redis param group"
  type        = string
  default     = ""
}

variable "sidekiq_server_count" {
  description = "Number of instances to create for sidekiq"
  type        = number
  default     = 0
}

variable "enable_cloudwatch_alerts" {
  description = "Setup cloudwatch alerts"
  type        = bool
  default     = false
}

variable "cloudwatch_alerts_sns_arn" {
  description = "The ARN of the SNS topic to which cloudwatch alerts will be sent"
  type        = string
  default     = ""
}
