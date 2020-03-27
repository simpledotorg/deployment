variable "deployment_name" {
  description = "The name of the deployment"
  type        = string
}

variable "ec2_instance_type" {
  description = "The type of instance for ec2 servers"
  type        = string
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

variable "instance_security_groups" {
  description = "Security groups assigned to instances"
  type        = list(string)
}

variable "app_server_count" {
  description = "The number of instance for ec2 servers"
  type        = number
  default     = 1
}

variable "sidekiq_server_count" {
  description = "Number of instances to create for sidekiq"
  type        = number
  default     = 0
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

variable "monitoring_server_count" {
  description = "Number of instances to create for monitoring"
  type        = number
  default     = 0
}

variable "storage_server_count" {
  description = "Number of instances to create for storage"
  type        = number
  default     = 0
}

