###
### Provision the RDS instances
###

### Simple Server
# QA
resource "aws_db_instance" "qa_simple_db" {
  allocated_storage          = 20
  auto_minor_version_upgrade = false
  engine                     = "postgres"
  engine_version             = "10.3"
  identifier                 = "redapp-db-qa"
  instance_class             = "db.t2.micro"
  name                       = "redapp"
  username                   = "redapp_db_master_user"
  copy_tags_to_snapshot      = true
  publicly_accessible        = true
  skip_final_snapshot        = true
  tags {
    workload-type = "other"
  }
}

# Staging
resource "aws_db_instance" "staging_simple_db" {
  allocated_storage          = 20
  auto_minor_version_upgrade = false
  engine                     = "postgres"
  engine_version             = "10.3"
  identifier                 = "redapp-db-staging-02"
  instance_class             = "db.t2.micro"
  name                       = "redapp"
  username                   = "redapp_db_master_user"
  copy_tags_to_snapshot      = true
  publicly_accessible        = true
  skip_final_snapshot        = true
  tags {
    workload-type = "other"
  }
}

# Sandbox
resource "aws_db_instance" "sandbox_simple_db" {
  storage_encrypted          = true
  allocated_storage          = 100
  auto_minor_version_upgrade = false
  engine                     = "postgres"
  engine_version             = "10.3"
  identifier                 = "simple-db-sandbox-01"
  instance_class             = "db.t2.medium"
  name                       = "sandbox_simple_db"
  username                   = "simple_db_master_user"
  copy_tags_to_snapshot      = true
  publicly_accessible        = false
  skip_final_snapshot        = true
  tags {
    workload-type = "production"
  }
  password = "${var.sandbox_db_password}"
  vpc_security_group_ids = ["${aws_security_group.sandbox_simple_database.id}"]
}

# resource "aws_db_instance" "replica_sandbox_simple_db" {
#   identifier                 = "simple-db-sandbox-01-read-replica"
#   replicate_source_db        = "${aws_db_instance.sandbox_simple_db.identifier}"
#   instance_class             = "db.t2.medium"
#   storage_encrypted          = true
#   auto_minor_version_upgrade = false
#   publicly_accessible        = false
# }

# Production
resource "aws_db_instance" "production_simple_db" {
  storage_encrypted          = true
  monitoring_interval        = 15
  allocated_storage          = 100
  auto_minor_version_upgrade = false
  engine                     = "postgres"
  engine_version             = "10.3"
  identifier                 = "redapp-db-production-01"
  instance_class             = "db.t2.medium"
  name                       = "redapp"
  username                   = "redapp_db_master_user"
  copy_tags_to_snapshot      = true
  publicly_accessible        = false
  skip_final_snapshot        = true
  tags {
    workload-type = "production"
  }
}

resource "aws_db_instance" "replica_production_simple_db" {
  identifier                 = "redapp-db-production-01-read-replica"
  replicate_source_db        = "${aws_db_instance.production_simple_db.identifier}"
  instance_class             = "db.t2.medium"
  storage_encrypted          = true
  auto_minor_version_upgrade = false
  publicly_accessible        = false
}

# Card Reader
resource "aws_db_instance" "production_cardreader_db" {
  allocated_storage          = 20
  engine                     = "postgres"
  engine_version             = "10.6"
  identifier                 = "cardreader-db-production"
  instance_class             = "db.t2.micro"
  name                       = "cardreader_production"
  username                   = "cardreader_db_master_user"
  copy_tags_to_snapshot      = true
  publicly_accessible        = false
  skip_final_snapshot        = true
  tags {
    workload-type = "production"
  }
}
