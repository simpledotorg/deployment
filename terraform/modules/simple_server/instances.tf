resource "aws_instance" "ec2_simple_server" {
  ami = data.aws_ami.ubuntu.id
  instance_type = var.ec2_instance_type

  key_name = var.aws_key_name
  count = var.server_count

  root_block_device {
    volume_size = "30"
  }

  associate_public_ip_address = true

  vpc_security_group_ids = concat(var.instance_security_groups, [
    aws_security_group.sg_simple_server.id
  ])

  tags = {
    Name = "${format("simple-server-%s-%03d", var.deployment_name, count.index + 1)}"
  }
}

resource "aws_security_group" "sg_simple_server" {
  name = "sg_simple_server_${var.deployment_name}"
  description = "Security group for ${var.deployment_name} server"
}

resource "aws_lb_target_group" "simple_server_target_group" {
  name = "${var.deployment_name}-servers"
  vpc_id = var.server_vpc_id
  port = 80
  protocol = "HTTP"
  health_check {
    path = "/api/v3/ping"
    matcher = "200"
  }
}

resource "aws_lb_target_group_attachment" "simple_server_target" {
  count = length(aws_instance.ec2_simple_server) 
  target_group_arn = aws_lb_target_group.simple_server_target_group.arn
  target_id = aws_instance.ec2_simple_server[count.index].id
}

resource "aws_lb_listener_rule" "simple_server_listener_rule" {
  listener_arn = var.http_listener_arn
  
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.simple_server_target_group.arn
  }

  condition {
    field  = "host-header"
    values = var.host_urls
  }
}
