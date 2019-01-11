###
### Certificates
### 

resource "aws_acm_certificate" "simple_org" {
  domain_name = "*.simple.org"
}

resource "aws_acm_certificate" "simple_dot_org" {
  domain_name = "*.simple.org"
}
