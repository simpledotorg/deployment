# Set the variable value in *.tfvars file
# or using -var="do_token=..." CLI option
variable "do_token" {}

# Configure the DigitalOcean Provider
provider "digitalocean" {
  token = var.do_token
  version = "~> 1.12"
}

# Create a new Web Droplet in the nyc2 region
resource "digitalocean_droplet" "icmr-box" {
  image  = "ubuntu-16-04-x64"
  count  = 6
  name   = "p-icmr-box-${count.index + 1}"
  region = "blr1"
  size   = "c-2"
}
