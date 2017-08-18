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
