resource "aws_alb" "simple_env_proxy" {
  name     = "simple-env-proxy"
  internal = false
  subnets  = aws_default_subnet.default.*.id

  tags = {
    Name = "Simple Env Proxy"
  }
}

resource "aws_alb_listener" "simple_listener_http" {
  load_balancer_arn = aws_alb.simple_env_proxy.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/html"
      message_body = "<h1>Not Found</h1>"
      status_code  = "404"
    }
  }
}
