data "aws_ami" "ubuntu" {
  //  ami-0c28d7c6dd94fb3a7 is Canonical Community Ubuntu 16.04 LTS
  //  ami-08e5424edfe926b43 is Canonical Community Ubuntu 20.04 LTS
  filter {
    name   = "image-id"
    values = var.ec2_ubuntu_version == "16.04" ? ["ami-0c28d7c6dd94fb3a7"] : ["ami-08e5424edfe926b43"] # Defaults to Ubuntu 20.04
  }

  owners = ["099720109477"] # Use official Canonical Ubuntu AMIs
}
