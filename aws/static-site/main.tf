data "aws_iam_policy_document" "policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["arn:aws:s3:::${var.name}/*"]

    principals {
      type        = "AWS"
      identifiers = ["${aws_cloudfront_origin_access_identity.access.iam_arn}"]
    }
  }

  statement {
    actions   = ["s3:ListBucket"]
    resources = ["arn:aws:s3:::${var.name}"]

    principals {
      type        = "AWS"
      identifiers = ["${aws_cloudfront_origin_access_identity.access.iam_arn}"]
    }
  }
}

resource "aws_s3_bucket" "server" {
  bucket = "${var.name}"
  acl    = "private"

  policy = "${data.aws_iam_policy_document.policy.json}"

  website {
    index_document = "${var.index_document}"
    error_document = "${var.error_document}"
  }
}

resource "aws_cloudfront_origin_access_identity" "access" {}

resource "aws_cloudfront_distribution" "dist" {
  origin {
    domain_name = "${aws_s3_bucket.server.bucket_domain_name}"
    origin_id   = "origin-bucket-${aws_s3_bucket.server.id}"

    s3_origin_config {
      origin_access_identity = "${aws_cloudfront_origin_access_identity.access.cloudfront_access_identity_path}"
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "${var.index_document}"

  aliases = ["${var.name}", "${var.aliases}"]

  default_cache_behavior {
    allowed_methods        = ["HEAD", "GET", "OPTIONS"]
    cached_methods         = ["HEAD", "GET", "OPTIONS"]
    compress               = true
    viewer_protocol_policy = "${var.viewer_protocol_policy}"
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

  custom_error_response {
    error_code         = 404
    response_code      = "${var.index_document != var.error_document ? 404 : 200}"
    response_page_path = "/${var.error_document}"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = "${var.acm_certificate_arn}"
    minimum_protocol_version = "TLSv1"
    ssl_support_method       = "sni-only"
  }
}
