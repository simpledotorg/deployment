resource "aws_elasticache_cluster" "simple_elasticache" {
  count                = var.create_redis_instance ? 1 : 0
  cluster_id           = "${var.deployment_name}-elasticache"
  engine               = "redis"
  node_type            = "cache.t2.small"
  num_cache_nodes      = 1
  parameter_group_name = var.redis_subnet_group_name
  engine_version       = "5.0.3"
  port                 = 6379
  security_group_ids   = aws_security_group.sg_simple_redis.*.id
  subnet_group_name    = var.redis_subnet_group_name

  tags = {
    Name = "simple-elasticache-sandbox"
  }
}

resource "aws_elasticache_cluster" "simple_elasticache" {
  count                = var.create_redis_cache_instance ? 1 : 0
  cluster_id           = "${var.deployment_name}-elasticache"
  engine               = "redis"
  node_type            = "cache.t2.small"
  num_cache_nodes      = 1
  parameter_group_name = var.redis_subnet_group_name
  engine_version       = "5.0.3"
  port                 = 16379
  security_group_ids   = aws_security_group.sg_simple_redis.*.id
  subnet_group_name    = var.redis_subnet_group_name

  tags = {
    Name = "simple-elasticache-sandbox"
  }
}

resource "aws_security_group" "sg_simple_redis" {
  count       = var.create_redis_instance ? 1 : 0
  name        = "sg_simple_redis_${var.deployment_name}"
  description = "Security group for ${var.deployment_name} redis"
  vpc_id      = var.server_vpc_id

  ingress {
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [aws_security_group.sg_simple_server.id]
  }
}
