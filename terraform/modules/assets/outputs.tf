output "bucket_name" {
  value = "${google_storage_bucket.assets.name}"
}

output "bucket_url" {
  description = "Base URL of the assets bucket"
  value       = "${google_storage_bucket.assets.url}"
}
