# Reserve a static internal IP address for Cloud SQL:
resource "google_compute_global_address" "private_ip_address" {
  provider      = "google-beta"
  name          = "cloud-sql-private-ip"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = "${var.network}"
}

resource "google_service_networking_connection" "private_vpc_connection" {
  provider                = "google-beta"
  network                 = "${var.network}"
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = ["${google_compute_global_address.private_ip_address.name}"]
}

resource "google_sql_database_instance" "instance" {
  provider         = "google"
  database_version = "POSTGRES_9_6"
  depends_on       = ["google_service_networking_connection.private_vpc_connection"]
  name             = "${var.instance_name}"
  region           = "${var.region}"

  lifecycle {
    prevent_destroy = true
  }

  settings {
    tier = "db-f1-micro"

    ip_configuration {
      # Instance is not publicly accessible:
      authorized_networks = []
      ipv4_enabled        = false
      private_network     = "${var.network}"
    }
  }

  # Manually disable public IP since `ipv4_enabled = false` seems to bear no effect, contrary to the docs:
  provisioner "local-exec" {
    command = "gcloud sql instances patch ${var.instance_name} --no-assign-ip"
  }
}

resource "google_sql_user" "app_user" {
  instance = "${google_sql_database_instance.instance.name}"
  name     = "${var.username}"
  password = "${var.password}"
}

resource "google_sql_database" "app" {
  name     = "${var.db_name}"
  instance = "${google_sql_database_instance.instance.name}"
}
