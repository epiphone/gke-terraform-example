resource "google_dns_managed_zone" "default" {
  name     = "default-zone"
  dns_name = "${var.domain}."
}

resource "google_dns_record_set" "default" {
  name         = "${google_dns_managed_zone.default.dns_name}"
  type         = "A"
  ttl          = 300
  managed_zone = "${google_dns_managed_zone.default.name}"
  rrdatas      = ["${var.load_balancer_ip_address}"]
}
