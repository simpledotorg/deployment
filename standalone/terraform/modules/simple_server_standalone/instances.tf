# Create a new Web Droplet in the blr1 region
resource "digitalocean_droplet" "simple_digitalocean_instance" {
  image    = "ubuntu-16-04-x64"
  count    = var.server_count
  name     = "${var.deployment_name}-box-${count.index + 1}"
  region   = "blr1"
  size     = var.digitalocean_instance_type
  ssh_keys = var.ssh_keys
}

output "instance_ips" {
  value = digitalocean_droplet.simple_digitalocean_instance.*.ipv4_address
}
