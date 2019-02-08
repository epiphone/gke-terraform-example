variable "env" {
  type = "string"
}

variable "name" {
  default = "gke-assets"
  type    = "string"
}

variable "location" {
  default = "europe-north1"
  type    = "string"
}

variable "storage_class" {
  default = "REGIONAL"
  type    = "string"
}
