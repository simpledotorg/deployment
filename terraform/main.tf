#
# Set remote backend to save state
#
terraform {
  backend "s3" {
    encrypt = true
  }
}

#
# Set up the AWS SSH key pair
#
resource "aws_key_pair" "simple_aws_key" {
  key_name   = "redapp-server-staging"
  public_key = "${file("~/.ssh/simple_aws_key.pub")}"
}

#
# Provision the EC2 instances
#
resource "aws_instance" "qa_simple_server" {
  ami = "${var.qa_ami}"
  instance_type = "t2.micro"
  key_name = "${aws_key_pair.simple_aws_key.key_name}"

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
resource "aws_eip" "qa_simple_server" {
  instance    = "${aws_instance.qa_simple_server.id}"
  tags {
    Name = "qa-server-ipaddress"
  }
}

#
# Output provisioned IPs
#
output "qa-simple-server-ip" {
  value = "${aws_eip.qa_simple_server.public_ip}"
}
