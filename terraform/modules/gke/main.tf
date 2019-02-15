data "google_container_engine_versions" "gke_versions" {}

data "google_project" "project" {}

data "google_container_registry_image" "default" {
  name   = "gke-${var.env}"
  region = "eu"
  tag    = "${var.image_tag}"
}

resource "google_compute_network" "gke_network" {
  provider                = "google"
  name                    = "${var.network_name}"
  auto_create_subnetworks = false
}

resource "google_container_cluster" "gke_cluster" {
  provider           = "google-beta"
  min_master_version = "${data.google_container_engine_versions.gke_versions.latest_master_version}"
  name               = "gke-cluster-${var.env}"

  # Using full path instead of just "${google_compute_network.gke_network.name}" to avoid unnecessary updates
  # https://github.com/terraform-providers/terraform-provider-google/issues/1792
  network = "projects/${data.google_project.project.project_id}/global/networks/${google_compute_network.gke_network.name}"

  remove_default_node_pool = true

  addons_config {
    http_load_balancing {
      disabled = false
    }

    kubernetes_dashboard {
      disabled = true
    }
  }

  private_cluster_config {
    master_ipv4_cidr_block = "172.16.0.0/28"
    enable_private_nodes   = true
  }

  # Disable Basic Auth
  master_auth {
    username = ""
    password = ""
  }

  # Kubernetes master's external IP is only accessible from ${var.kubernetes_master_allowed_ip}
  master_authorized_networks_config {
    cidr_blocks = [
      {
        cidr_block = "${var.k8s_master_allowed_ip}/32"
      },
    ]
  }

  # Use ABAC until official Kubernetes plugin supports RBAC
  enable_legacy_abac = "true"

  # Enable alias IP addresses https://cloud.google.com/kubernetes-engine/docs/how-to/alias-ips
  ip_allocation_policy {
    create_subnetwork = true
    subnetwork_name   = "${var.network_name}"
  }

  lifecycle {
    ignore_changes = ["node_pool"]
  }

  node_pool {
    name = "default-pool"
  }
}

resource "google_container_node_pool" "gke_pool" {
  provider   = "google"
  name       = "gke-pool-${var.env}"
  cluster    = "${google_container_cluster.gke_cluster.name}"
  node_count = "${var.node_count}"

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
    machine_type = "${var.machine_type}"
  }
}
