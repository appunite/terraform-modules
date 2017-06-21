resource "aws_elb" "balancer" {
  name            = "${var.name}"
  subnets         = ["${var.public_subnets}"]
  security_groups = ["${aws_security_group.elb.id}"]

  cross_zone_load_balancing = true
  connection_draining       = true

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 10
    timeout             = 5
    target              = "${var.health_check_target}"
    interval            = 30
  }

  listener {
    instance_port     = "${var.instance_port}"
    instance_protocol = "${var.instance_protocol}"
    lb_port           = 80
    lb_protocol       = "http"
  }

  listener {
    instance_port      = "${var.instance_port}"
    instance_protocol  = "${var.instance_protocol}"
    lb_port            = 443
    lb_protocol        = "ssl"
    ssl_certificate_id = "${var.ssl_certificate_id}"
  }
}

resource "aws_elb_attachment" "instances" {
  count = "${length(var.instances)}"

  elb = "${aws_elb.balancer.id}"
  instance = "${var.instances[count.index]}"
}

resource "aws_proxy_protocol_policy" "websockets" {
  load_balancer  = "${aws_elb.balancer.name}"
  instance_ports = ["${var.instance_port}"]
}

resource "aws_security_group" "elb" {
  vpc_id = "${var.vpc_id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
