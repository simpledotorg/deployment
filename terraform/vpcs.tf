resource "aws_vpc" "simple_servers" {
  cidr_block = "172.32.0.0/16"

  tags {
    Name = "simple-servers"
  }
}

resource "aws_vpc" "simple_databases" {
  cidr_block = "172.31.0.0/16"
  tags {
    Name = "simple-database"
  }
}
