data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_internet_gateway" "default" {
  filter {
    name   = "attachment.vpc-id"
    values = [aws_default_vpc.default.id]
  }
}

output "database_vpc_id" {
  value       = aws_vpc.database_vpc.id
  description = "ID for the Database VPC"
}

output "server_vpc_id" {
  value       = aws_default_vpc.default.id
  description = "ID for the server VPC"
}

output "database_subnet_group_name" {
  value       = aws_db_subnet_group.default.name
  description = "Name for database subnet group"
}

output "redis_subnet_group_name" {
  value       = aws_elasticache_subnet_group.default.name
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

output "standalone_instance_security_groups" {
  value = [
    aws_security_group.allow_all_outbound.id,
    aws_security_group.allow_all_inbound.id
  ]
}

output "https_listener_arn" {
  value = var.create_alb ? aws_alb_listener.simple_listener_https[0].arn : null
}

output "load_balancer_arn_suffix" {
  value = var.create_alb ? aws_alb.simple_env_proxy[0].arn_suffix : null
}

output "load_balancer_public_dns" {
  value = var.create_alb ? aws_alb.simple_env_proxy[0].dns_name : null
}
