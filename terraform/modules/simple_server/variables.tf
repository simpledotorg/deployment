variable "deployment_name" {
  description = "The name of the deployment"
  type        = string
}

variable "ec2_instance_type" {
  description = "The type of instance for ec2 servers"
  type        = string
}

variable "database_ec2_instance_type" {
  description = "The type of instance for ec2 servers"
  type        = string
  default     = ""
}

variable "redis_ec2_instance_type" {
  description = "The type of instance for ec2 servers"
  type        = string
  default     = ""
}

variable "server_count" {
  description = "The number of instance for ec2 servers"
  type        = number
  default     = 1
}

variable "database_server_count" {
  description = "The number of instance for database ec2 servers"
  type        = number
  default     = 0
}

variable "redis_server_count" {
  description = "The number of instance for redis ec2 servers"
  type        = number
  default     = 0
}

variable "database_username" {
  description = "Database Username"
  type        = string
  default     = ""
}

variable "database_password" {
  description = "Database Password"
  type        = string
  default     = ""
}

variable "database_vpc_id" {
  description = "Database vpc-id"
  type        = string
  default     = ""
}

variable "database_subnet_group_name" {
  description = "Database vpc-id"
  type        = string
  default     = ""
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

variable "host_urls" {
  description = "List of host URL"
  type        = list(string)
}

variable "create_rds_instances" {
  description = "Create a RDS instance"
  type = bool
  default = true
}

variable "create_database_replica" {
  description = "Create an RDS replica instance"
  type        = bool
  default     = false
}

variable "create_ec2_load_balancer" {
  description = "Create a load balancer ec2 instance"
  type        = bool
  default     = false
}

variable "create_redis_instance" {
  description = "Create an additional elasticache redis instance"
  type        = bool
  default     = false
}

variable "redis_subnet_group_name" {
  description = "Name of the redis subnet"
  type        = string
  default     = ""
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
