output "client_certificate" {
  value     = "${google_container_cluster.gke_cluster.master_auth.0.client_certificate}"
  sensitive = true
}

output "client_key" {
  value     = "${google_container_cluster.gke_cluster.master_auth.0.client_key}"
  sensitive = true
}

output "cluster_ca_certificate" {
  value     = "${google_container_cluster.gke_cluster.master_auth.0.cluster_ca_certificate}"
  sensitive = true
}

output "cluster_name" {
  value = "${google_container_cluster.gke_cluster.name}"
}

output "cluster_zone" {
  value = "${google_container_cluster.gke_cluster.zone}"
}

output "host" {
  value     = "${google_container_cluster.gke_cluster.endpoint}"
  sensitive = true
}

output "network" {
  value = "${google_compute_network.gke_network.self_link}"
}
