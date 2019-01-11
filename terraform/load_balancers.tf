##
## Load balancers
##

## ALB
resource "aws_alb" "simple_env_proxy" {
  name            = "simple-env-proxy"
  internal        = false
  security_groups = [
    "${aws_vpc.simple_servers_01.default_security_group_id}",
    "${aws_security_group.allow_http_https_01.id}"
  ]

  subnets = [
    "${aws_subnet.simple_servers_01_01.id}",
    "${aws_subnet.simple_servers_01_02.id}"
  ]
  
  tags {
    Name = "Simple environment proxy"
  }
}

### Listeners
resource "aws_alb_listener" "simple_listener_https" {
  load_balancer_arn = "${aws_alb.simple_env_proxy.arn}"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "${aws_acm_certificate.simple_dot_org.arn}"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/html"
      message_body = "<h1>Not Found</h1>"
      status_code  = "404"
    }
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
  vpc_id = "${aws_vpc.simple_servers_01.id}"
  health_check {
    path = "/api/v2/ping"
  }
}

resource "aws_alb_target_group_attachment" "sandbox_simple_server_01" {
  target_group_arn = "${aws_alb_target_group.sandbox_simple_servers.arn}"
  target_id        = "${aws_instance.sandbox_simple_server.id}"
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
}

resource "aws_alb_listener_rule" "sandbox_listener_rule_dashboard" {
  listener_arn = "${aws_alb_listener.simple_listener_https.arn}"
  priority     = 200

  action {
    type             = "forward"
    target_group_arn = "${aws_alb_target_group.sandbox_simple_servers.arn}"
  }

  condition {
    field  = "host-header"
    values = ["dashboard-sandbox.simple.org"]
  }
}
