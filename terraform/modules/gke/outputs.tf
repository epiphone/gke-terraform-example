output "cluster_name" {
  value = "${google_container_cluster.gke_cluster.name}"
}

output "cluster_zone" {
  value = "${google_container_cluster.gke_cluster.zone}"
}

output "image_url" {
  value = "${data.google_container_registry_image.default.image_url}"
}

output "network" {
  value = "${google_compute_network.gke_network.self_link}"
}
