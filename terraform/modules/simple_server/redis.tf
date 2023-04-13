resource "aws_elasticache_cluster" "simple_elasticache" {
  count                = var.create_redis_cache_instance ? 1 : 0
  cluster_id           = "${var.deployment_name}-elasticache"
  engine               = "redis"
  node_type            = var.redis_node_type
  num_cache_nodes      = 1
  parameter_group_name = var.redis_subnet_group_name
  engine_version       = "5.0.6"
  port                 = 6379
  security_group_ids   = aws_security_group.sg_simple_redis.*.id
  subnet_group_name    = var.redis_subnet_group_name
  apply_immediately    = true

  tags = {
    Name = "simple-elasticache"
  }
}

resource "aws_elasticache_cluster" "simple_elasticache_2" {
  count                = var.create_redis_sidekiq_instance ? 1 : 0
  cluster_id           = "${var.deployment_name}-elasticache-2"
  engine               = "redis"
  node_type            = var.redis_node_type
  num_cache_nodes      = 1
  parameter_group_name = var.redis_subnet_group_name
  engine_version       = "5.0.6"
  port                 = 6379
  security_group_ids   = aws_security_group.sg_simple_redis.*.id
  subnet_group_name    = var.redis_subnet_group_name
  apply_immediately    = true

  tags = {
    Name = "simple-elasticache"
  }
}

resource "aws_security_group" "sg_simple_redis" {
  count       = (var.create_redis_cache_instance || var.create_redis_sidekiq_instance) ? 1 : 0
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

output "cache_redis_url" {
  value = aws_elasticache_cluster.simple_elasticache[0].cache_nodes.0.address
}

output "sidekiq_redis_url" {
  value = aws_elasticache_cluster.simple_elasticache_2[0].cache_nodes.0.address
}
