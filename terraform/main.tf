resource "aws_amplify_app" "website" {
  name       = var.domain_name
  repository = var.repository

  platform = "WEB"

  environment_variables = {
    BASEURL = var.domain_name
  }

  custom_rule {
    source = "/.well-known/<*>"
    status = "200"
    target = "/well-known/<*>.txt"
  }

  custom_rule {
    source = "/<*>"
    status = "404"
    target = "/404.html"
  }
}

resource "aws_amplify_branch" "main" {
  app_id                      = aws_amplify_app.website.id
  branch_name                 = "main"
  stage                       = "PRODUCTION"
  enable_pull_request_preview = true
  framework                   = "Web"
}

resource "aws_amplify_domain_association" "website" {
  app_id                 = aws_amplify_app.website.id
  domain_name            = var.domain_name
  enable_auto_sub_domain = true

  certificate_settings {
    custom_certificate_arn = module.acm_certificate.arn
    type                   = "CUSTOM"
  }

  sub_domain {
    branch_name = aws_amplify_branch.main.branch_name
    prefix      = "staging"
  }

  sub_domain {
    branch_name = aws_amplify_branch.main.branch_name
    prefix      = "mta-sts"
  }

  lifecycle {
    ignore_changes = [sub_domain]
  }
}

# module "cdn" {
#   source  = "cloudposse/cloudfront-s3-cdn/aws"
#   version = "0.98.0"

#   name                        = "cdn"
#   comment                     = var.comment
#   origin_bucket               = module.website.bucket_id
#   aliases                     = [local.hostname, local.mta_sts]
#   external_aliases            = var.aliases
#   dns_alias_enabled           = true
#   dns_allow_overwrite         = true
#   website_enabled             = true
#   s3_website_password_enabled = true
#   allow_ssl_requests_only     = false
#   price_class                 = "PriceClass_All"
#   default_ttl                 = 86400
#   min_ttl                     = 3600
#   max_ttl                     = 2592000
#   minimum_protocol_version    = "TLSv1.2_2021"
#   parent_zone_id              = aws_route53_zone.this.id
#   acm_certificate_arn         = module.acm_certificate.arn
#   context                     = module.this.context
#   custom_error_response = [
#     {
#       error_caching_min_ttl = null
#       error_code            = 404
#       response_code         = 200
#       response_page_path    = "/404.html"
#     }
#   ]
# }

locals {
  hostname = join(".", compact([var.host_name, aws_route53_zone.this.name]))
  mta_sts  = join(".", ["mta-sts", aws_route53_zone.this.name])
}
