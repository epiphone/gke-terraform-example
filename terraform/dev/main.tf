locals {
  env = "dev"
}

terraform {
  required_version = "0.11.11"

  backend "gcs" {
    bucket      = "tf-state-gke-dev"
    credentials = "terraform-service-account-dev-credentials.json"
    prefix      = "terraform-state-dev"
  }
}

provider "google" {
  credentials = "${file("terraform-service-account-dev-credentials.json")}" # Make sure to exclude from version control!
  project     = "${var.project_id}"
  region      = "${var.region}"
  zone        = "${var.zone}"
}

resource "google_container_cluster" "gke_cluster" {
  name                     = "gke-cluster-${local.env}"
  remove_default_node_pool = true

  node_pool {
    name = "default-pool"
  }
}

resource "google_container_node_pool" "gke_pool" {
  name       = "gke-pool-${local.env}"
  cluster    = "${google_container_cluster.gke_cluster.name}"
  node_count = "1"

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]

    disk_size_gb = 10
    machine_type = "n1-standard-1"
  }
}
