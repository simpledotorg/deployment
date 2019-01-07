###
### Assign Elastic IPs
###

### Simple Server
# QA
resource "aws_eip" "qa_simple_server" {
  instance    = "${aws_instance.qa_simple_server.id}"
  tags {
    Name = "qa-server-ipaddress"
  }
}

# Staging
resource "aws_eip" "staging_simple_server" {
  instance    = "${aws_instance.staging_simple_server.id}"
  tags {
    Name = "staging-server-ipaddress"
  }
}

# # Sandbox
# resource "aws_eip" "sandbox_simple_server" {
#   instance    = "${aws_instance.sandbox_simple_server.id}"
#   tags {
#     Name = "sandbox-server-ipaddress"
#   }
# }

# Production
resource "aws_eip" "production_simple_server" {
  instance    = "${aws_instance.production_simple_server.id}"
  tags {
    Name = "production-server-ipaddress"
  }
}

# Cardreader
resource "aws_eip" "production_cardreader" {
  instance    = "${aws_instance.production_cardreader.id}"
  tags {
    Name = "cardreader-server-ipaddress"
  }
}
