module "cdn" {
  source  = "cloudposse/cloudfront-s3-cdn/aws"
  version = "0.96.2"

  name                        = "cdn"
  comment                     = var.comment
  origin_bucket               = module.website.bucket_id
  aliases                     = [local.hostname, local.mta_sts]
  external_aliases            = var.aliases
  dns_alias_enabled           = true
  dns_allow_overwrite         = true
  website_enabled             = true
  s3_website_password_enabled = true
  allow_ssl_requests_only     = false
  price_class                 = "PriceClass_All"
  default_ttl                 = 86400
  min_ttl                     = 3600
  max_ttl                     = 2592000
  minimum_protocol_version    = "TLSv1.2_2021"
  parent_zone_id              = aws_route53_zone.this.id
  acm_certificate_arn         = module.acm_certificate.arn
  context                     = module.this.context
  custom_error_response = [
    {
      error_caching_min_ttl = null
      error_code            = 404
      response_code         = 200
      response_page_path    = "/404.html"
    }
  ]
}

module "acm_certificate" {
  source  = "cloudposse/acm-request-certificate/aws"
  version = "0.18.0"

  domain_name                       = aws_route53_zone.this.name
  zone_id                           = aws_route53_zone.this.id
  process_domain_validation_options = true
  ttl                               = "300"
  subject_alternative_names         = [join(".", ["*", aws_route53_zone.this.name])]
}

locals {
  hostname = join(".", compact([var.host_name, aws_route53_zone.this.name]))
  mta_sts  = join(".", ["mta-sts", aws_route53_zone.this.name])
}
