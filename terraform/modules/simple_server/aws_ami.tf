data "aws_ami" "ubuntu" {
  filter {
    name = "image-id"
    values = var.ec2_ubuntu_version == "16.04" ? ["ami-0c28d7c6dd94fb3a7"] : ["ami-0c1a7f89451184c8b"]
  }

  owners = ["099720109477"] # Use official Canonical Ubuntu AMIs
}
