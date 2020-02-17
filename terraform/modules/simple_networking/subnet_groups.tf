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

