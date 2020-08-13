variable "deployment_name" {
  description = "The name of the deployment"
  type        = string
}

variable "server_count" {
  description = "The number of instance for ec2 servers"
  type        = number
  default     = 1
}

variable "digitalocean_instance_type" {
  description = "The type of instance for ec2 servers"
  type        = string
}

variable "ssh_keys" {
  description = "The ssh key fingerprints to add"
  type        = list(string)
}
