data "aws_ami" "ubuntu" {
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name = "image-id"
    values = ["ami-0c28d7c6dd94fb3a7"]
  }

  owners = ["099720109477"] # Use official Canonical Ubuntu AMIs
}
