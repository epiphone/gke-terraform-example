resource "google_storage_bucket" "assets" {
  name          = "gke-sample-assets-bucket-${var.env}"
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
