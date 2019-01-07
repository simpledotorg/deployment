#
# Set up security groups
#

# Allow SSH
resource "aws_security_group" "allow_ssh" {
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
}

resource "aws_security_group_rule" "allow_outbound" {
  security_group_id = "${aws_security_group.allow_outbound.id}"
  type="egress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]

}
