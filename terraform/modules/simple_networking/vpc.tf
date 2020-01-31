resource "aws_default_vpc" "default" {
	tags = {
		Name = "Default VPC"
	}
}

resource "aws_default_subnet" "default" {
	count             = length(data.aws_availability_zones.available.names)
	availability_zone = data.aws_availability_zones.available.names[count.index]

	tags = {
		Name = format("Default VPC subnet %03d", count.index + 1)
	}
}

resource "aws_vpc" "database_vpc" {
	cidr_block = var.database_vpc_cidr

	tags = { 
		Name = "${format("simple-database-vpc-%s", var.deployment_name)}"
	}
}

resource "aws_subnet" "database_vpc_subnet" {
	count                   = length(data.aws_availability_zones.available.names)
	availability_zone       = data.aws_availability_zones.available.names[count.index]
	map_public_ip_on_launch = true
	cidr_block              = cidrsubnet(aws_vpc.database_vpc.cidr_block, 4, count.index)
	vpc_id                  = aws_vpc.database_vpc.id

	tags = {
		Name = "${format("simple-database-vpc-%s-subnet-%03d", var.deployment_name, count.index + 1)}"
	}
}

resource "aws_vpc_peering_connection" "peering_from_servers_to_database" {
	vpc_id      = aws_default_vpc.default.id
	peer_vpc_id = aws_vpc.database_vpc.id
	auto_accept = true

	tags = {
		Name = "${format("peering-simple-servers-vpc-to-database-vpc-%s", var.deployment_name)}"
	}
}
