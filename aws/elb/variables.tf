variable "vpc_id" {}

variable "name" {}

variable "public_subnets" {
  type = "list"
}

variable "instance_port" {}

variable "instance_protocol" {
  default = "tls"
}

variable "health_check_target" {}

variable "ssl_certificate_id" {}
