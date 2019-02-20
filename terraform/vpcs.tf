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

# New VPC
resource "aws_vpc" "simple_servers_01" {
  cidr_block = "172.33.0.0/16"

  tags {
    Name = "simple-server-01"
  }
}

resource "aws_subnet" "simple_servers_01_01" {
  cidr_block = "172.33.0.0/20"
  vpc_id     = "${aws_vpc.simple_servers_01.id}"
  availability_zone = "${var.aws_availability_zone_a}"
  tags {
    Name = "simple-servers-subnet-01"
  }
}

resource "aws_subnet" "simple_servers_01_02" {
  cidr_block = "172.33.16.0/20"
  vpc_id     = "${aws_vpc.simple_servers_01.id}"
  availability_zone = "${var.aws_availability_zone_b}"
  tags {
    Name = "simple-servers-subnet-02"
  }
}

resource "aws_vpc_peering_connection" "simple_servers_01_simple_databases" {
  vpc_id      = "${aws_vpc.simple_servers_01.id}"
  peer_vpc_id = "${aws_vpc.simple_databases.id}"
  auto_accept = true
}

resource "aws_internet_gateway" "simple_servers_01" {
  vpc_id      = "${aws_vpc.simple_servers_01.id}"
  tags {
    Name = "simple-servers-01-gateway"
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
  tags {
    Name = "simple-databases-subnet-01"
  }
}

resource "aws_subnet" "simple_databases_02" {
  map_public_ip_on_launch = true
  cidr_block              = "172.31.0.0/20"
  vpc_id                  = "${aws_vpc.simple_databases.id}"
  tags {
    Name = "simple-databases-subnet-02"
  }
}

### Route Tables 
resource "aws_route_table" "simple_servers_01" {
  vpc_id = "${aws_vpc.simple_servers_01.id}"

  route {
    cidr_block = "${aws_vpc.simple_databases.cidr_block}" 
    vpc_peering_connection_id = "${aws_vpc_peering_connection.simple_servers_01_simple_databases.id}"
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.simple_servers_01.id}"
  }
}

resource "aws_route_table_association" "simple_servers_01_01" {
  subnet_id      = "${aws_subnet.simple_servers_01_01.id}"
  route_table_id = "${aws_route_table.simple_servers_01.id}"
}

resource "aws_route_table_association" "simple_servers_01_02" {
  subnet_id      = "${aws_subnet.simple_servers_01_02.id}"
  route_table_id = "${aws_route_table.simple_servers_01.id}"
}

resource "aws_route_table" "simple_databases" {
  vpc_id = "${aws_vpc.simple_databases.id}"

  route {
    cidr_block = "${aws_vpc.simple_servers_01.cidr_block}" 
    vpc_peering_connection_id = "${aws_vpc_peering_connection.simple_servers_01_simple_databases.id}"
  }
}

