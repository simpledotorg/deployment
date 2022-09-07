resource "aws_db_parameter_group" "simple-database-parameter-group" {
  count = var.database_custom_param_group ? 1 : 0
  name   = "simple-db-${var.deployment_name}-parameter-group-pg14"
  family = "postgres14"

  parameter {
    name  = "random_page_cost"
    value = var.database_random_page_cost
  }

  parameter {
    name  = "work_mem"
    value = var.database_work_mem
  }

  parameter {
    name  = "max_parallel_workers_per_gather"
    value = var.database_max_parallel_workers_per_gather
  }

  parameter {
    name  = "log_min_duration_statement"
    value = "100"
  }

  parameter {
    name  = "rds.log_retention_period"
    value = "4320"
  }
}

resource "aws_db_instance" "simple-database" {
  storage_encrypted             = true
  allocated_storage             = var.database_allocated_storage
  auto_minor_version_upgrade    = false
  engine                        = "postgres"
  engine_version                = var.database_postgres_version
  count                         = 1
  identifier                    = format("simple-db-%s-%03d", replace(var.deployment_name, "_", "-"), count.index + 1)
  instance_class                = var.database_instance_type
  db_name                       = format("simple_db_%s_%03d", replace(var.deployment_name, "-", "_"), count.index + 1)
  username                      = var.database_username
  final_snapshot_identifier     = format("simple-db-%s-%03d-final", replace(var.deployment_name, "_", "-"), count.index + 1)
  copy_tags_to_snapshot         = true
  publicly_accessible           = false
  db_subnet_group_name          = var.database_subnet_group_name
  backup_retention_period       = 35
  password                      = var.database_password
  vpc_security_group_ids        = [aws_security_group.sg_simple_database.id]
  performance_insights_enabled  = true
  parameter_group_name          = var.database_custom_param_group ? "simple-db-${var.deployment_name}-parameter-group-pg14" : null
  apply_immediately             = true

  tags = {
    workload-type = var.deployment_name
  }
}

resource "aws_security_group" "sg_simple_database" {
  name        = "sg_simple_database_${var.deployment_name}"
  description = "Security group for ${var.deployment_name} database"
  vpc_id      = var.database_vpc_id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.sg_simple_server.id]
  }
}

resource "aws_db_instance" "replica_simple_database" {
  count               = var.create_database_replica ? (length(aws_db_instance.simple-database)) : 0
  identifier          = format("replica-simple-db-%s-%03d", replace(var.deployment_name, "_", "-"), count.index + 1)
  replicate_source_db = aws_db_instance.simple-database[count.index].identifier
  instance_class      = var.database_replica_instance_type
  storage_encrypted   = true
  skip_final_snapshot = true
  parameter_group_name = var.database_custom_param_group ? "simple-db-${var.deployment_name}-parameter-group-pg14" : null
  final_snapshot_identifier = null
}

output "database_url" {
  value = aws_db_instance.simple-database[0].endpoint
}

