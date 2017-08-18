variable "name" {}
variable "log_bucket" {}

variable "acm_certificate_arn" {
  default = ""
}

variable "aliases" {
  type = "list"
}

variable "index_document" {
  default = "index.html"
}

variable "error_document" {
  default = "error.html"
}

variable "viewer_protocol_policy" {
  default = "redirect-to-https"
}
