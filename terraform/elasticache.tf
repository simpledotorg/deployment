# For SBX
resource "aws_elasticache_cluster" "sandbox_simple_elasticache" {
  cluster_id           = "sandbox-elasticache"
  engine               = "redis"
  node_type            = "cache.t2.small"
  num_cache_nodes      = 1
  parameter_group_name = "${aws_elasticache_parameter_group.sandbox_redis_paramgrp.name}"
  engine_version       = "5.0.3"
  port                 = 6379
  security_group_ids   = ["${aws_security_group.sandbox_simple_elasticache.id}"]
  subnet_group_name    = "${aws_elasticache_subnet_group.sandbox_redis_subnet_group.name}"
  tags {
    Name = "simple-elasticache-sandbox"
  }
}

resource "aws_elasticache_parameter_group" "sandbox_redis_paramgrp" {
  name   = "sandbox-redis5"
  family = "redis5.0"
}

resource "aws_elasticache_subnet_group" "sandbox_redis_subnet_group" {
  name       = "sandbox-redis-subnet-group"
  subnet_ids = ["${aws_subnet.simple_servers_01_01.id}", "${aws_subnet.simple_servers_01_02.id}"]
}

# For qa
resource "aws_elasticache_cluster" "qa_simple_elasticache" {
  cluster_id           = "qa-elasticache"
  engine               = "redis"
  node_type            = "cache.t2.micro"
  num_cache_nodes      = 1
  parameter_group_name = "${aws_elasticache_parameter_group.qa_redis_paramgrp.name}"
  engine_version       = "5.0.3"
  port                 = 6379
  security_group_ids   = ["${aws_security_group.qa_simple_elasticache.id}"]
  subnet_group_name    = "${aws_elasticache_subnet_group.qa_redis_subnet_group.name}"
  tags {
    Name = "simple-elasticache-qa"
  }
}

resource "aws_elasticache_parameter_group" "qa_redis_paramgrp" {
  name   = "qa-redis5"
  family = "redis5.0"
}

resource "aws_elasticache_subnet_group" "qa_redis_subnet_group" {
  name       = "qa-redis-subnet-group"
  subnet_ids = ["${aws_subnet.simple_servers_01.id}"]
}

# For staging
resource "aws_elasticache_cluster" "staging_simple_elasticache" {
  cluster_id           = "staging-elasticache"
  engine               = "redis"
  node_type            = "cache.t2.micro"
  num_cache_nodes      = 1
  parameter_group_name = "${aws_elasticache_parameter_group.staging_redis_paramgrp.name}"
  engine_version       = "5.0.3"
  port                 = 6379
  security_group_ids   = ["${aws_security_group.staging_simple_elasticache.id}"]
  subnet_group_name    = "${aws_elasticache_subnet_group.staging_redis_subnet_group.name}"
  tags {
    Name = "simple-elasticache-staging"
  }
}

resource "aws_elasticache_parameter_group" "staging_redis_paramgrp" {
  name   = "staging-redis5"
  family = "redis5.0"
}

resource "aws_elasticache_subnet_group" "staging_redis_subnet_group" {
  name       = "staging-redis-subnet-group"
  subnet_ids = ["${aws_subnet.simple_servers_01.id}"]
}
