###
### Load balancers
###

### ALB
resource "aws_alb" "simple_env_proxy" {
  name = "simple-env-proxy"
  internal = false
  
  tags {
    Name = "Simple environment proxy"
  }
}

### Listeners
resource "aws_alb_listener" "simple_listener_https" {
  load_balancer_arn = "${aws_alb.simple_env_proxy.arn}"
  port              = "443"
  protocol          = "HTTPS"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_alb_target_group.sandbox_simple_servers.arn}"
  }
}

resource "aws_alb_listener" "simple_listener_http" {
  load_balancer_arn = "${aws_alb.simple_env_proxy.arn}"
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

### Target Groups

resource "aws_alb_target_group" "sandbox_simple_servers" {
  name = "sandbox-simple-servers"
  port = 443
  protocol = "HTTPS"
  vpc_id = "${aws_vpc.simple_servers.id}"
}

resource "aws_alb_target_group_attachment" "sandbox_simple_server_01" {
  target_group_arn = "${aws_alb_target_group.sandbox_simple_servers.arn}"
  target_id        = "${aws_instance.sandbox_simple_server.id}"
  port             = 80
}

### Listenrer rules

resource "aws_alb_listener_rule" "sandbox_listener_rule" {
  listener_arn = "${aws_alb_listener.simple_listener_https.arn}"
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = "${aws_alb_target_group.sandbox_simple_servers.arn}"
  }

  condition {
    field  = "host-header"
    values = ["api-sandbox.simple.org"]
  }

  condition {
    field  = "host-header"
    values = ["dashboard-sandbox.simple.org"]
  }
}
