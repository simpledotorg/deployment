#
# Set up the AWS SSH key pair
#
resource "aws_key_pair" "redapp-staging" {
  key_name   = "redapp-server-staging"
  public_key = "${file("~/.ssh/redapp-server-staging.pub")}"
}

#
# Provision the EC2 instances
#
resource "aws_instance" "qa_simple_server" {
  ami = "${var.qa_ami}"
  instance_type = "t2.micro"
  key_name = "${aws_key_pair.redapp-staging.key_name}"

  root_block_device {
    volume_size = "8"
  }

  tags {
    Name = "simple-server-vpc2-qa"
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
