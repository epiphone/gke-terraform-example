variable "assets_bucket_name" {
  type = "string"
}

variable "enable_cdn" {
  type    = "string"
  default = true
}

variable "k8s_backend_service_name" {
  type    = "string"
  default = ""
}
