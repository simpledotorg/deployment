variable "deployment_name" {
	description = "The name of the deployment"
	type        = string
}

variable "database_vpc_cidr" {
	description = "The CIDR block for VPC with databases"
	type        = string
}

variable "database_vpc_subnet_1_cidr" {
	description = "The CIDR block for VPC with databases"
	type        = string
}

variable "database_vpc_subnet_2_cidr" {
	description = "The CIDR block for VPC with databases"
	type        = string
}
