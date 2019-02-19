output "public_address" {
  value = "${google_compute_global_address.default.address}"
}

output "urlmap_name" {
  value = "${local.url_map_name}"
}
