# make sure you have domain in route53
# as this module uses dns validation method
# currently it does not support SAN
# (only 1 domain)
# due to the logic of dns validation records

resource "aws_acm_certificate" "public_cert" {
  domain_name       = var.domain
  validation_method = "DNS"

  # we usually want wildcard and domain. in case of extras - that optional
  subject_alternative_names = concat(["*.${var.domain}"], var.alt_domains)
  tags                      = var.tags

  lifecycle {
    create_before_destroy = true
  }
}
locals {
 splited_domain = split(".",var.domain)
 sld = var.sld ? 3:2
}
# get root domain
data "aws_route53_zone" "zone" {
  name         = join(".",slice(local.splited_domain, length(local.splited_domain) - local.sld ,length(local.splited_domain)))
  private_zone = false
}

resource "aws_route53_record" "cert_validation" {
  name = aws_acm_certificate.public_cert.domain_validation_options.0.resource_record_name
  type = aws_acm_certificate.public_cert.domain_validation_options.0.resource_record_type
  records = [aws_acm_certificate.public_cert.domain_validation_options.0.resource_record_value]
  zone_id = data.aws_route53_zone.zone.id
  ttl     = 60
}
output "certificate" {
  value=  aws_acm_certificate.public_cert.id
  description = "return arn of certificate"   
}
