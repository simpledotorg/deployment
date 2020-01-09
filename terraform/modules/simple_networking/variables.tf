variable "deployment_name" {
	description = "The name of the deployment"
	type        = string
}

variable "database_vpc_cidr" {
	description = "The CIDR block for VPC with databases"
	type        = string
}

variable "create_redis_subnet" {
	description = "Create a subnet redis instance"
	type = bool
	default = false
}
