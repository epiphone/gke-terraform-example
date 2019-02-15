variable "env" {
  type = "string"
}

variable "image_tag" {
  type = "string"
}

variable "k8s_master_allowed_ip" {
  type = "string"
}

variable "machine_type" {
  default = "n1-standard-1"
  type    = "string"
}

variable "network_name" {
  type = "string"
}

variable "node_count" {
  default = "1"
  type    = "string"
}

variable "region" {
  type = "string"
}
