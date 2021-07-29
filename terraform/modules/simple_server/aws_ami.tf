data "aws_ami" "ubuntu" {
  //  ami-0c28d7c6dd94fb3a7 is Canonical Community Ubuntu 16.04 LTS
  //  ami-0c1a7f89451184c8b is Canonical Community Ubuntu 20.04 LTS
  filter {
    name = "image-id"
    values = var.ec2_ubuntu_version == "16.04" ? ["ami-0c28d7c6dd94fb3a7"] : ["ami-0c1a7f89451184c8b"] # Defaults to Ubuntu 20.04
  }

  owners = ["099720109477"] # Use official Canonical Ubuntu AMIs
}
