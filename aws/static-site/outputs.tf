output "name" {
  value = "${aws_cloudfront_distribution.dist.domain_name}"
}

output "zone_id" {
  value = "${aws_cloudfront_distribution.dist.hosted_zone_id}"
}
