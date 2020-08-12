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
    key = "ethiopia.tfstate"
    region = "ap-south-1"
    profile = "development"
  }
}

# Configure the DigitalOcean Provider
provider "digitalocean" {
  token = var.do_token
  version = "~> 1.12"
}

module "ethiopia_demo" {
  source                     = "../modules/simple_server_standalone"
  deployment_name            = "ethiopia-demo"
  server_count               = 2
  digitalocean_instance_type = "s-2vcpu-2gb"
  ssh_keys                   = [var.kitallis_fingerprint, var.prabhanshu_fingerprint]
}

output "instance_ips" {
  value = module.ethiopia_demo.instance_ips
}
