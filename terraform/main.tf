resource "aws_amplify_app" "website" {
  name       = var.domain_name
  repository = var.repository

  platform          = "WEB"
  production_branch = "main"
  access_token      = var.gh_access_token

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
    prefix      = var.host_name
  }

  sub_domain {
    branch_name = aws_amplify_branch.main.branch_name
    prefix      = "mta-sts"
  }

  lifecycle {
    ignore_changes = [sub_domain]
  }
}
