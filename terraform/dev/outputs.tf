output "cluster_name" {
  value = "${module.gke.cluster_name}"
}

output "cluster_zone" {
  value = "${module.gke.cluster_zone}"
}

output "domain" {
  value = "${var.domain}"
}

output "image_url" {
  value = "${module.gke.image_url}"
}

output "k8s_master_allowed_ip" {
  value     = "${var.k8s_master_allowed_ip}"
  sensitive = true
}

output "k8s_rendered_template" {
  value     = "${data.template_file.k8s.rendered}"
  sensitive = true
}

output "project_id" {
  value = "${var.project_id}"
}

output "static_assets_bucket_url" {
  value = "${module.assets.bucket_url}"
}

output "urlmap_name" {
  value = "${module.lb.urlmap_name}"
}
