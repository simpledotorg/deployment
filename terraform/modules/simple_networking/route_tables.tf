resource "aws_route_table" "route_table_from_servers_to_database" {
	vpc_id = aws_default_vpc.default.id

	route {
		cidr_block                = aws_vpc.database_vpc.cidr_block
		vpc_peering_connection_id = aws_vpc_peering_connection.peering_from_servers_to_database.id
	}

	route {
		cidr_block = "0.0.0.0/0"
		gateway_id = data.aws_internet_gateway.default.id
	}

	tags = {
		Name = "${format("route-table-simple-servers-vpc-to-database-vpc-%s", var.deployment_name)}"
	}
}

resource "aws_route_table" "route_table_database_to_servers" {
	vpc_id = aws_vpc.database_vpc.id

	route {
		cidr_block                = aws_default_vpc.default.cidr_block
		vpc_peering_connection_id = aws_vpc_peering_connection.peering_from_servers_to_database.id
	}

	tags = {
		Name = "${format("route-table-simple-database-vpc-to-servers-vpc-%s", var.deployment_name)}"
	}
}

resource "aws_route_table_association" "route_table_database_subnet_association" {
	count          = length(aws_subnet.database_vpc_subnet)
	subnet_id      = aws_subnet.database_vpc_subnet[count.index].id
	route_table_id = aws_route_table.route_table_database_to_servers.id
}

resource "aws_route_table_association" "route_table_default_subnet_association" {
	count          = length(aws_default_subnet.default)
	subnet_id      = aws_default_subnet.default[count.index].id
	route_table_id = aws_route_table.route_table_from_servers_to_database.id
}

