# Set the variable value in *.tfvars file
# or using -var="do_token=..." CLI option
variable "do_token" {}
variable "fingerprint_1" {}
variable "fingerprint_2" {}

#
# Set remote backend to save state
#
terraform {
  backend "s3" {
    bucket = "simple-server-development-terraform-state"
    encrypt = true
    key = "dummy.tfstate"
    region = "ap-south-1"
    profile = "development"
  }
}

# Configure the DigitalOcean Provider
provider "digitalocean" {
  token = var.do_token
  version = "~> 1.12"
}

# Create a new Web Droplet in the nyc2 region
resource "digitalocean_droplet" "icmr-box" {
  image  = "ubuntu-16-04-x64"
  count  = 7
  name   = "p-icmr-box-${count.index + 1}"
  region = "blr1"
  size   = "c-2"
  ssh_keys = [var.fingerprint_1, var.fingerprint_2]
}

output "instance_ips" {
  value = digitalocean_droplet.icmr-box.*.ipv4_address
}
