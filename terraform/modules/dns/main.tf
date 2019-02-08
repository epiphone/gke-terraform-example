resource "google_dns_managed_zone" "root" {
  name     = "root-zone"
  dns_name = "${var.domain}."
}

resource "google_dns_record_set" "root" {
  name         = "${google_dns_managed_zone.root.dns_name}"
  type         = "A"
  ttl          = 300
  managed_zone = "${google_dns_managed_zone.root.name}"
  rrdatas      = ["${var.assets_ip_address}"]
}

resource "google_dns_record_set" "api" {
  count        = "${var.cluster_ip_address != "" ? 1 : 0}"
  name         = "api.${google_dns_managed_zone.root.dns_name}"
  type         = "A"
  ttl          = 300
  managed_zone = "${google_dns_managed_zone.root.name}"
  rrdatas      = ["${var.cluster_ip_address}"]
}
