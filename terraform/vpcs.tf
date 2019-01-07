# Instances
resource "aws_vpc" "simple_servers" {
  cidr_block = "172.32.0.0/16"

  tags {
    Name = "simple-servers"
  }
}

resource "aws_subnet" "simple_servers_01" {
  cidr_block = "172.32.0.0/16"
  vpc_id     = "${aws_vpc.simple_servers.id}"
  tags {
    Name = "simple-servers-subnet-01"
  }
}

# Databases
resource "aws_vpc" "simple_databases" {
  cidr_block = "172.31.0.0/16"
  tags {
    Name = "simple-database"
  }
}

resource "aws_subnet" "simple_databases_01" {
  map_public_ip_on_launch = true
  cidr_block              = "172.31.16.0/20"
  vpc_id                  = "${aws_vpc.simple_databases.id}"
  # tags {
  #   Name = "simple-databases-subnet-01"
  # }
}

resource "aws_subnet" "simple_databases_02" {
  map_public_ip_on_launch = true
  cidr_block              = "172.31.0.0/20"
  vpc_id                  = "${aws_vpc.simple_databases.id}"
  # tags {
  #   Name = "simple-databases-subnet-02"
  # }
}
