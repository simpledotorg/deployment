data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "database_vpc" {
  cidr_block = var.database_vpc_cidr

  tags = { 
    Name = "${format("simple-database-vpc-%s", var.deployment_name)}"
  }
}

resource "aws_subnet" "database_vpc_subnet" {
  count = length(data.aws_availability_zones.available.names)
  availability_zone = data.aws_availability_zones.available.names[count.index]
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

resource "aws_route_table" "route_table_from_servers_to_database" {
  vpc_id      = aws_default_vpc.default.id

  route {
    cidr_block = aws_vpc.database_vpc.cidr_block
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
    cidr_block = aws_default_vpc.default.cidr_block
    vpc_peering_connection_id = aws_vpc_peering_connection.peering_from_servers_to_database.id
  }

  tags = {
    Name = "${format("route-table-simple-database-vpc-to-servers-vpc-%s", var.deployment_name)}"
  }
}

resource "aws_route_table_association" "route_table_database_subnet_association" {
  count = length(aws_subnet.database_vpc_subnet)
  subnet_id      = aws_subnet.database_vpc_subnet[count.index].id
  route_table_id = aws_route_table.route_table_database_to_servers.id
}

resource "aws_route_table_association" "route_table_default_subnet_association" {
  count = length(aws_default_subnet.default)
  subnet_id      = aws_default_subnet.default[count.index].id
  route_table_id = aws_route_table.route_table_from_servers_to_database.id
}

resource "aws_db_subnet_group" "default" {
  name       = "main"
  subnet_ids = aws_subnet.database_vpc_subnet.*.id
  tags = {
    Name = "simple-database-subnet-group"
  }
}

resource "aws_elasticache_subnet_group" "default" {
  name       = "redis-subnet-group"
  subnet_ids = aws_default_subnet.default.*.id
}

resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
}

resource "aws_default_subnet" "default" {
  count = length(data.aws_availability_zones.available.names)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name = format("Default VPC subnet %03d", count.index + 1)
  }
}

data "aws_internet_gateway" "default" {
  filter {
    name   = "attachment.vpc-id"
    values = [aws_default_vpc.default.id]
  }
}

output "database_vpc_id" {
  value = aws_vpc.database_vpc.id
  description = "ID for the Database VPC"
}

output "server_vpc_id" {
  value = aws_default_vpc.default.id
  description = "ID for the server VPC"
}

output "database_subnet_group_name" {
  value = aws_db_subnet_group.default.name
  description = "Name for database subnet group"
}

output "redis_subnet_group_name" {
  value = aws_elasticache_subnet_group.default.name
  description = "Name for redis subnet group"
}

output "instance_security_groups" {
  value = [
    aws_security_group.allow_ssh.id,
    aws_security_group.allow_http.id,
    aws_security_group.allow_https.id,
    aws_security_group.allow_all_outbound.id
  ]
}

output "http_listener_arn" {
  value = aws_alb_listener.simple_listener_http.arn
}
