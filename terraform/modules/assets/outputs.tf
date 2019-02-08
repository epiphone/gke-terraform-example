output "bucket_url" {
  description = "Base URL of the assets bucket"
  value       = "${google_storage_bucket.assets.url}"
}

output "public_address" {
  value = "${google_compute_global_forwarding_rule.assets.ip_address}"
}

output "urlmap_name" {
  value = "${google_compute_url_map.assets.name}"
}
