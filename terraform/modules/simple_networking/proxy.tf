resource "aws_acm_certificate" "cert" {
  private_key = var.private_key
  certificate_body = var.certificate_body
  certificate_chain = var.certificate_chain
}

resource "aws_acm_certificate" "additional_certs" {
  count             = length(var.additional_certificates)
  private_key       = file(var.additional_certificates[count.index]["private_key_file"])
  certificate_body  = file(var.additional_certificates[count.index]["body_file"])
  certificate_chain = file(var.additional_certificates[count.index]["chain_file"])
}

resource "aws_alb" "simple_env_proxy" {
  name     = "simple-env-proxy"
  internal = false
  subnets  = aws_default_subnet.default.*.id
  idle_timeout = 600
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
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = aws_acm_certificate.cert.arn

  lifecycle {
    // We've started using an amazon provided certificate in Bangladesh,
    // which is manually generated for now. This is for terraform to
    // ignore the outdated certificate.
    ignore_changes = [certificate_arn]
  }

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/html"
      message_body = "<h1>Not Found</h1>"
      status_code  = "404"
    }
  }
}

resource "aws_lb_listener_certificate" "additional_listener_certificates" {
  count           = length(aws_acm_certificate.additional_certs)
  listener_arn    = aws_alb_listener.simple_listener_https.arn
  certificate_arn = aws_acm_certificate.additional_certs[count.index].arn
}
