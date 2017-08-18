resource "aws_s3_bucket" "server" {
  bucket = "${var.from}"
  acl = "public-read"

  website {
    redirect_all_requests_to = "${var.to}"
  }
}

resource "aws_cloudfront_distribution" "dist" {
  origin {
    domain_name = "${aws_s3_bucket.server.website_endpoint}"
    origin_id   = "origin-bucket-${aws_s3_bucket.server.id}"

    custom_origin_config {
      http_port = 80
      https_port = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }
  }

  enabled         = true
  is_ipv6_enabled = true

  aliases = ["${var.from}", "${var.other_domains}"]

  default_cache_behavior {
    allowed_methods        = ["HEAD", "GET"]
    cached_methods         = ["HEAD", "GET"]
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
