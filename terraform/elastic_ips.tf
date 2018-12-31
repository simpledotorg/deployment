#
# Assign Elastic IPs
#

resource "aws_eip" "qa_simple_server" {
  instance    = "${aws_instance.qa_simple_server.id}"
  tags {
    Name = "qa-server-ipaddress"
  }
}

resource "aws_eip" "staging_simple_server" {
  instance    = "${aws_instance.staging_simple_server.id}"
  tags {
    Name = "staging-server-ipaddress"
  }
}

