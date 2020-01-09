resource "aws_elasticache_parameter_group" "redis_paramgrp" {
	name   = "redis5"
	family = "redis5.0"
}

output "redis_param_group_name" {
	value = aws_elasticache_parameter_group.redis_paramgrp.name
}
