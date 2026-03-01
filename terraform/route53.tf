resource "aws_route53_zone" "this" {
  name          = var.domain_name
  comment       = var.comment
  force_destroy = false

  lifecycle {
    ignore_changes = [vpc]
  }
}

module "website" {
  source  = "cloudposse/s3-bucket/aws"
  version = "4.11.0"

  bucket_name             = aws_route53_zone.this.name
  s3_object_ownership     = "BucketOwnerEnforced"
  block_public_policy     = false
  restrict_public_buckets = false
  versioning_enabled      = false
  context                 = module.this.context
  website_configuration = [
    {
      index_document = "index.html"
      error_document = "/404.html"
      routing_rules  = null
    }
  ]
}

locals {
  caa_report_recipient = can(regex("@", var.caa_report_recipient)) ? var.caa_report_recipient : "${var.caa_report_recipient}@${aws_route53_zone.this.name}"
  tls_report_recipient = can(regex("@", var.tls_report_recipient)) ? var.tls_report_recipient : "${var.tls_report_recipient}@${aws_route53_zone.this.name}"
}
