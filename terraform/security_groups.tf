#
# Set up security groups
#

# Allow SSH
resource "aws_security_group" "allow_ssh" {
  vpc_id = "${aws_vpc.simple_servers.id}"
  name        = "allow-ssh"
  description = "Allow SSH inbound traffic"
}

resource "aws_security_group_rule" "allow_ssh" {
  security_group_id = "${aws_security_group.allow_ssh.id}"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group" "allow_http_https" {
  name        = "allow-https"
  description = "Allow HTTP/HTTPS inbound traffic"
  vpc_id = "${aws_vpc.simple_servers.id}"
}

# Allow HTTP and HTTPS
resource "aws_security_group_rule" "allow_http_https" {
  security_group_id = "${aws_security_group.allow_http_https.id}"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "allow_http_https-1" {
  security_group_id = "${aws_security_group.allow_http_https.id}"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_blocks       = ["0.0.0.0/0"]
}

# Allow Postgresql
resource "aws_security_group" "allow_postgresql" {
  name        = "allow-postgresql"
  description = "Allow PostgreSQL inbound traffic"
}

resource "aws_security_group_rule" "allow_postgresql" {
  security_group_id = "${aws_security_group.allow_postgresql.id}"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 5432
  to_port           = 5432
  cidr_blocks       = ["0.0.0.0/0"]
}

# Allow outbound
resource "aws_security_group" "allow_outbound" {
  name        = "allow-all-outbound"
  description = "Allow all outbound traffic"
  vpc_id = "${aws_vpc.simple_servers.id}"
}

resource "aws_security_group_rule" "allow_outbound" {
  security_group_id = "${aws_security_group.allow_outbound.id}"
  type="egress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]

}

# Allow Monit
resource "aws_security_group" "allow_monit" {
  name        = "allow-monit"
  description = "Allow monit inbound traffic"
  vpc_id = "${aws_vpc.simple_servers.id}"
}

resource "aws_security_group_rule" "allow_monit" {
  security_group_id = "${aws_security_group.allow_monit.id}"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 2812
  to_port           = 2812
  cidr_blocks       = ["0.0.0.0/0"]
}

# Sandbox security group
resource "aws_security_group" "sandbox_simple_server" {
  name        = "simple-server-sandbox-sg"
  description = "Security group for andbox simple servers"
  vpc_id = "${aws_vpc.simple_servers.id}"
}
