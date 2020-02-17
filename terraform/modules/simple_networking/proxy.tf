resource "aws_acm_certificate" "cert" {
  private_key = var.private_key
  certificate_body = var.certificate_body
  certificate_chain = var.certificate_chain
}

resource "aws_alb" "simple_env_proxy" {
  name     = "simple-env-proxy"
  internal = false
  subnets  = aws_default_subnet.default.*.id
  security_groups = [
    aws_security_group.allow_all_inbound.id,
    aws_security_group.allow_all_outbound.id
  ]

  tags = {
    Name = "Simple Env Proxy"
  }
}

resource "aws_alb_listener" "simple_listener_http" {
  load_balancer_arn = aws_alb.simple_env_proxy.arn
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

resource "aws_alb_listener" "simple_listener_https" {
  load_balancer_arn = aws_alb.simple_env_proxy.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.cert.arn

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/html"
      message_body = "<h1>Not Found</h1>"
      status_code  = "404"
    }
  }
}
