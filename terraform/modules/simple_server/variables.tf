variable "deployment_name" {
  description = "The name of the deployment"
  type        = string
}

variable "ec2_instance_type" {
  description = "The type of instance for ec2 servers"
  type        = string
}

variable "ec2_ubuntu_version" {
  description = "The ubuntu version to be installed on the ec2 servers"
  type        = string
  default     = "20.04"
}

variable "ec2_volume_size" {
  description = "The disk size on the root block device for ec2 servers"
  type        = string
  default     = "30"
}

variable "server_count" {
  description = "The number of instance for ec2 servers"
  type        = number
  default     = 1
}

variable "database_instance_type" {
  description = "The type of instance for database servers"
  type        = string
  default     = "db.t2.medium"
}

variable "database_postgres_version" {
  description = "The postgres version to be installed on RDS"
  type        = string
  default     = "10.3"
}

variable "database_replica_instance_type" {
  description = "The type of instance for database replica servers"
  type        = string
  default     = "db.t2.medium"
}

variable "database_allocated_storage" {
  description = "The storage allocated for database servers (in GB)"
  type        = string
  default     = "100"
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

variable "database_custom_param_group" {
  description = "Boolean to control whether or not to apply custom pg params"
  type        = bool
  default     = false
}

variable "database_random_page_cost" {
  description = "RDS variable value for random_page_cost"
  type        = string
  default     = 4
}

variable "database_work_mem" {
  description = "RDS variable value for work_mem"
  type        = string
  default     = 4000
}

variable "database_max_parallel_workers_per_gather" {
  description = "RDS variable value for max_parallel_workers_per_gather"
  type        = string
  default     = 2
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

variable "create_redis_cache_instance" {
  description = "Create a dedicated redis instance for app cache"
  type        = bool
  default     = false
}

variable "create_redis_sidekiq_instance" {
  description = "Create a dedicated redis instance for sidekiq"
  type        = bool
  default     = false
}

variable "redis_node_type" {
  description = "The type of instance for redis server"
  default     = "cache.t2.small"
  type        = string
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
