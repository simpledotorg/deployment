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
  type = list(string)
}

variable "aws_key_name" { 
  description = "Name of the default aws key"
  type = string
}

variable  "server_vpc_id" {
  description = "Server vpc-id"
  type        = string
}

variable "http_listener_arn" {
  description = "HTTP listener arn" 
  type = string
}

variable "host_urls" {
  description = "List of host URL" 
  type = list(string)
}
