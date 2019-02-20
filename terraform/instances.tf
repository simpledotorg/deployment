###
### Provision the EC2 instances
###

### Simple Server
# QA
resource "aws_instance" "qa_simple_server" {
  ami = "${var.qa_ami}"
  instance_type = "t2.micro"
  key_name = "${aws_key_pair.simple_aws_key.key_name}"

  root_block_device {
    volume_size = "8"
  }

  subnet_id = "${aws_subnet.simple_servers_01.id}"

  tags {
    Name = "simple-server-vpc2-qa"
  }
}
 
# Staging
resource "aws_instance" "staging_simple_server" {
  ami = "${var.staging_ami}"
  instance_type = "t2.micro"
  key_name = "${aws_key_pair.simple_aws_key.key_name}"

  root_block_device {
    volume_size = "8"
  }

  subnet_id = "${aws_subnet.simple_servers_01.id}"

  tags {
    Name = "simple-server-vpc2-staging"
  }
}

# Sandbox
resource "aws_instance" "sandbox_simple_server" {
  ami = "${var.production_ami}"
  instance_type = "t2.medium"
  key_name = "${aws_key_pair.simple_aws_key.key_name}"

  root_block_device {
    volume_size = "30"
  }

  subnet_id = "${aws_subnet.simple_servers_01_01.id}"

  vpc_security_group_ids = [
    "${aws_security_group.allow_ssh_01.id}",
    "${aws_security_group.allow_http_https_01.id}",
    "${aws_security_group.allow_outbound_01.id}",
    "${aws_security_group.sandbox_simple_server.id}"
  ]

  associate_public_ip_address = true

  tags {
    Name = "simple-server-vpc2-sandbox"
  }
}

# Production
resource "aws_instance" "production_simple_server" {
  ami = "${var.production_ami}"
  instance_type = "t2.medium"
  key_name = "${aws_key_pair.simple_aws_key.key_name}"

  root_block_device {
    volume_size = "30"
  }

  subnet_id = "${aws_subnet.simple_servers_01.id}"

  tags {
    Name = "simple-server-vpc2-production"
  }
}

# Cardreader
resource "aws_instance" "production_cardreader" {
  ami = "${var.cardreader_ami}"
  instance_type = "t2.micro"
  key_name = "${aws_key_pair.simple_aws_key.key_name}"

  root_block_device {
    volume_size = "8"
  }

  subnet_id = "${aws_subnet.simple_servers_01.id}"

  tags {
    Name = "cardreader-vpc2-production"
  }
}
