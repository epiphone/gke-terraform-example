locals {
  url_map_name = "gke-url-map"
}

data "google_compute_backend_service" "k8s" {
  count = "${var.k8s_backend_service_name == "" ? 0 : 1}"
  name  = "${var.k8s_backend_service_name}"
}

resource "google_compute_backend_bucket" "assets" {
  name        = "assets-backend"
  bucket_name = "${var.assets_bucket_name}"
  enable_cdn  = "${var.enable_cdn}"
}

resource "google_compute_global_address" "default" {
  name = "gke-public-address"
}

resource "google_compute_url_map" "assets_only" {
  count           = "${var.k8s_backend_service_name == "" ? 1 : 0}"
  name            = "${local.url_map_name}"
  default_service = "${google_compute_backend_bucket.assets.self_link}"
}

resource "google_compute_url_map" "assets_and_api" {
  count           = "${var.k8s_backend_service_name == "" ? 0 : 1}"
  name            = "${local.url_map_name}"
  default_service = "${google_compute_backend_bucket.assets.self_link}"

  host_rule {
    hosts        = ["*"]
    path_matcher = "default"
  }

  path_matcher {
    name            = "default"
    default_service = "${google_compute_backend_bucket.assets.self_link}"

    path_rule {
      paths   = ["/api", "/api/*"]
      service = "${data.google_compute_backend_service.k8s.self_link}"
    }
  }
}

resource "google_compute_target_http_proxy" "default" {
  name = "gke-http-proxy"

  # Workaround over Terraform's lack of conditional resources; will be resolved in upcoming version:
  url_map = "${var.k8s_backend_service_name == "" ?  join(" ", google_compute_url_map.assets_only.*.self_link) : join(" ", google_compute_url_map.assets_and_api.*.self_link)}"
}

resource "google_compute_global_forwarding_rule" "default" {
  name       = "gke-forwarding-rule"
  ip_address = "${google_compute_global_address.default.address}"
  target     = "${google_compute_target_http_proxy.default.self_link}"
  port_range = "80"
}
