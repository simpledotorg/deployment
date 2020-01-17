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
	type        = bool
	default     = false
}

variable "certificate_body" {
	description = "certificate for domain name"
	type        = string
}

variable "certificate_chain" {
	description = "certificate chain for domain name"
	type        = string
}

variable "private_key" {
	description = "private key for certificate"
	type        = string
}

