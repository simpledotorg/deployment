# Set the variable value in *.tfvars file
# or using -var="do_token=..." CLI option
variable "do_token" {}
variable "kitallis_fingerprint" {}
variable "prabhanshu_fingerprint" {}

#
# Set remote backend to save state
#
terraform {
  backend "s3" {
    bucket = "simple-server-development-terraform-state"
    encrypt = true
    key = "standalone-playground.tfstate"
    region = "ap-south-1"
    profile = "development"
  }
}

# Configure the DigitalOcean Provider
provider "digitalocean" {
  token = var.do_token
  version = "~> 1.12"
}

# Set server_count to the number of instances to create,
# this depends on how you want to distribute your services across multiple boxes.
module "icmr_playground" {
  source                     = "../modules/simple_server_standalone"
  deployment_name            = "icmr-playground"
  server_count               = 0
  digitalocean_instance_type = "s-2vcpu-2gb"
  ssh_keys                   = [var.kitallis_fingerprint, var.prabhanshu_fingerprint]
}

output "instance_ips" {
  value = module.icmr_playground.instance_ips
}
