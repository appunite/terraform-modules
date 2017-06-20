output "zone_id" {
  value = "${aws_elb.balancer.zone_id}"
}

output "dns_name" {
  value = "${aws_elb.balancer.dns_name}"
}
