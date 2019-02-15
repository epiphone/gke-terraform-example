locals {
  env = "dev"
}

terraform {
  required_version = "0.11.11"

  backend "gcs" {
    bucket = "gke-tfstate-dev"
  }
}

provider "google" {
  version = "2.0.0"

  project = "${var.project_id}"
  region  = "${var.region}"
  zone    = "${var.zone}"
}

provider "google-beta" {
  version = "2.0.0"

  project = "${var.project_id}"
  region  = "${var.region}"
  zone    = "${var.zone}"
}

module "gke" {
  source = "../modules/gke"

  env                   = "${local.env}"
  image_tag             = "${var.commit_hash}"
  k8s_master_allowed_ip = "${var.k8s_master_allowed_ip}"
  machine_type          = "n1-standard-1"
  network_name          = "gke-network"
  node_count            = "1"
  region                = "${var.region}"
}

module "cloud_sql" {
  source = "../modules/cloud_sql"

  network  = "${module.gke.network}"
  region   = "${var.region}"
  db_name  = "gke-${local.env}"
  username = "gke-${local.env}"
  password = "${var.db_password}"
}

module "assets" {
  source = "../modules/assets"

  env      = "${local.env}"
  location = "${var.region}"
}

module "dns" {
  source = "../modules/dns"

  domain             = "${var.domain}"
  assets_ip_address  = "${module.assets.public_address}"
  cluster_ip_address = "${var.cluster_ip_address}"
}

data "template_file" "k8s" {
  template = "${file("${path.module}/k8s.template.yml")}"

  vars = {
    cors_allow_origin = "http://${var.domain}"
    db_host           = "${module.cloud_sql.host}"
    db_name           = "${module.cloud_sql.db_name}"
    db_username       = "${module.cloud_sql.username}"
    db_password       = "${module.cloud_sql.password}"
    db_port           = "5432"
    image_url         = "${module.gke.image_url}"
    project_name      = "gke-${local.env}"
  }
}
