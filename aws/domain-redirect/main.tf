data "aws_iam_policy_document" "policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["arn:aws:s3:::${var.bucket_name}/*"]
  }

  principals {
    type        = "AWS"
    identifiers = ["${aws_cloudfront_origin_access_identity.access.iam_arn}"]
  }
}

resource "aws_cloudfront_origin_access_identity" "access" {}

resource "aws_s3_bucket" "dummy" {
  name = "${var.bucket_name}"

  policy = "${data.aws_iam_policy_document.policy.json}"

  website {
    redirect_all_requests_to = "${var.redirect_to}"
  }
}

resource "aws_cloudfront_distribution" "dist" {
  origin {
    domain_name = "${aws_s3_bucket.dummy.bucket_domain_name}"
    origin_id   = "origin-bucket-${aws_s3_bucket.dummy.id}"

    s3_origin_config {
      origin_access_identity = "${aws_cloudfront_origin_access_identity.access.cloudfront_access_identity_path}"
    }
  }

  enabled         = true
  is_ipv6_enabled = true

  aliases = ["${var.from_domains}"]

  default_cache_behavior {
    allowed_methods        = ["HEAD", "GET", "OPTIONS"]
    cached_methods         = ["HEAD", "GET", "OPTIONS"]
    viewer_protocol_policy = "allow-all"
    default_ttl            = 3600
    min_ttl                = 0
    max_ttl                = 86400
    target_origin_id       = "origin-bucket-${aws_s3_bucket.server.id}"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
  }

  viewer_certificate {
    acm_certificate_arn      = "${var.acm_certificate_arn}"
    minimum_protocol_version = "TLSv1"
    ssl_support_method       = "sni-only"
  }
}
