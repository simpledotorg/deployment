# For pre-prod
resource "aws_elasticache_cluster" "pre_prod_simple_elasticache" {
  cluster_id           = "preprod-elasticache"
  engine               = "redis"
  node_type            = "cache.t2.small"
  num_cache_nodes      = 1
  parameter_group_name = "${aws_elasticache_parameter_group.pre_prod_redis_paramgrp.name}"
  engine_version       = "5.0.3"
  port                 = 6379
  security_group_ids   = ["${aws_security_group.pre_prod_simple_elasticache.id}"]
  subnet_group_name    = "${aws_elasticache_subnet_group.pre_prod_redis_subnet_group.name}"
  tags {
    Name = "simple-elasticache-pre-prod"
  }
}

resource "aws_elasticache_parameter_group" "pre_prod_redis_paramgrp" {
  name   = "preprod-redis5"
  family = "redis5.0"
}

resource "aws_elasticache_subnet_group" "pre_prod_redis_subnet_group" {
  name       = "pre-prod-redis-subnet-group"
  subnet_ids = ["${aws_subnet.simple_servers_01_01.id}", "${aws_subnet.simple_servers_01_02.id}"]
}
