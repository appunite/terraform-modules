variable "vpc_id" {}

variable "name" {}

variable "public_subnets" {
  type = "list"
}

variable "instance_port" {}

variable "instance_protocol" {
  default = "TCP"
}

variable "health_check_target" {}

variable "ssl_certificate_id" {}

variable "instances" {
  type = "list"
}
