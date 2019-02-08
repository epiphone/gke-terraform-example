resource "google_storage_bucket" "assets" {
  name          = "${var.name}-bucket-${var.env}"
  location      = "${var.location}"
  storage_class = "${var.storage_class}"

  website {
    main_page_suffix = "index.html"
  }
}

resource "google_storage_bucket_iam_binding" "assets" {
  bucket = "${google_storage_bucket.assets.name}"
  role   = "roles/storage.legacyObjectReader"

  members = [
    "allUsers",
  ]
}

resource "google_compute_backend_bucket" "assets" {
  name        = "${var.name}-backend"
  description = "GKE sample app static resources backend"
  bucket_name = "${google_storage_bucket.assets.name}"
  enable_cdn  = true
}

resource "google_compute_global_address" "assets" {
  name = "${var.name}-public-address"
}

resource "google_compute_url_map" "assets" {
  name            = "${var.name}-map"
  description     = "URL map for the assets backend bucket"
  default_service = "${google_compute_backend_bucket.assets.self_link}"

  test {
    service = "${google_compute_backend_bucket.assets.self_link}"
    host    = "${google_compute_global_address.assets.address}"
    path    = "/index.html"
  }
}

resource "google_compute_target_http_proxy" "assets" {
  name    = "${var.name}-proxy"
  url_map = "${google_compute_url_map.assets.self_link}"
}

resource "google_compute_global_forwarding_rule" "assets" {
  name       = "${var.name}-rule"
  ip_address = "${google_compute_global_address.assets.address}"
  target     = "${google_compute_target_http_proxy.assets.self_link}"
  port_range = "80"
}
