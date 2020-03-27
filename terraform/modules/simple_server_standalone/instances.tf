resource "aws_instance" "ec2_simple_server" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.ec2_instance_type
  key_name                    = var.aws_key_name
  count                       = var.app_server_count
  associate_public_ip_address = true
  vpc_security_group_ids      = concat(var.instance_security_groups, [aws_security_group.sg_simple_server.id])

  root_block_device {
    volume_size = "30"
  }

  tags = {
    Name = format("simple-server-%s-%03d", var.deployment_name, count.index + 1)
  }
}

resource "aws_instance" "ec2_simple_sidekiq" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.ec2_instance_type
  key_name                    = var.aws_key_name
  count                       = var.sidekiq_server_count
  associate_public_ip_address = true
  vpc_security_group_ids      = concat(var.instance_security_groups, [aws_security_group.sg_simple_server.id])

  root_block_device {
    volume_size = "30"
  }

  tags = {
    Name = format("simple-server-sidekiq-%s-%03d", var.deployment_name, count.index + 1)
  }
}

resource "aws_instance" "ec2_simple_database" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.ec2_instance_type
  key_name                    = var.aws_key_name
  count                       = var.database_server_count
  associate_public_ip_address = true
  vpc_security_group_ids      = concat(var.instance_security_groups, [aws_security_group.sg_simple_server.id])

  root_block_device {
    volume_size = "30"
  }

  tags = {
    Name = format("simple-server-database-%s-%03d", var.deployment_name, count.index + 1)
  }
}

resource "aws_instance" "ec2_simple_redis" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.ec2_instance_type
  key_name                    = var.aws_key_name
  count                       = var.redis_server_count
  associate_public_ip_address = true
  vpc_security_group_ids      = concat(var.instance_security_groups, [aws_security_group.sg_simple_server.id])

  root_block_device {
    volume_size = "30"
  }

  tags = {
    Name = format("simple-server-redis-%s-%03d", var.deployment_name, count.index + 1)
  }
}

resource "aws_instance" "ec2_simple_load_balancer" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.ec2_instance_type
  key_name                    = var.aws_key_name
  count                       = 1
  associate_public_ip_address = true
  vpc_security_group_ids      = concat(var.instance_security_groups, [aws_security_group.sg_simple_server.id])

  root_block_device {
    volume_size = "30"
  }

  tags = {
    Name = format("simple-server-load-balancer-%s-%03d", var.deployment_name, count.index + 1)
  }
}

resource "aws_security_group" "sg_simple_server" {
  name        = "sg_simple_server_${var.deployment_name}"
  description = "Security group for ${var.deployment_name} server"
}
