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
 
resource "aws_instance" "staging_simple_server" {
  ami = "${var.staging_ami}"
  instance_type = "t2.micro"
  key_name = "${aws_key_pair.simple_aws_key.key_name}"

  root_block_device {
    volume_size = "8"
  }

  tags {
    Name = "simple-server-vpc2-staging"
  }
}

resource "aws_instance" "production_simple_server" {
  ami = "${var.production_ami}"
  instance_type = "t2.medium"
  key_name = "${aws_key_pair.simple_aws_key.key_name}"

  root_block_device {
    volume_size = "30"
  }

  tags {
    Name = "simple-server-vpc2-production"
  }
}
