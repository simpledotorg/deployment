#
# Set up the AWS SSH key pair
#
resource "aws_key_pair" "redapp-staging" {
  key_name   = "redapp-staging"
  public_key = "${file("~/.ssh/id_rsa.pub")}"
}

#
# Provision the EC2 instances
#
resource "aws_instance" "redapp-staging" {
  ami = "${data.aws_ami.ubuntu.id}"
  instance_type = "t2.micro"
  key_name = "${aws_key_pair.redapp-staging.key_name}"

  root_block_device {
    volume_size = "100"
  }

  security_groups = [
    "${aws_security_group.allow_ssh.name}",
    "${aws_security_group.allow_http_https.name}",
    "${aws_security_group.allow_outbound.name}"
  ]

  tags {
    Name = "redapp-staging"
  }
}

#
# Assign Elastic IPs
#
resource "aws_eip" "redapp-staging" {
  instance    = "${aws_instance.redapp-staging.id}"
}

#
# Output provisioned IPs
#
output "redapp-staging-ip" {
  value = "${aws_eip.redapp-staging.public_ip}"
}
