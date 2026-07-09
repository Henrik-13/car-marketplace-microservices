output "master_public_ip" {
  description = "Public IPv4 address of the K3s master node."
  value       = digitalocean_droplet.master.ipv4_address
}

output "worker_public_ip" {
  description = "Public IPv4 address of the K3s worker node."
  value       = digitalocean_droplet.worker.ipv4_address
}

output "floating_ip" {
  description = "Floating IP attached to the K3s master node."
  value       = digitalocean_floating_ip.master.ip_address
}

output "master_private_ip" {
  description = "Private IPv4 address of the K3s master node inside the VPC."
  value       = digitalocean_droplet.master.ipv4_address_private
}

output "api_fqdn" {
  description = "Public API hostname used by the ingress resources."
  value       = local.api_fqdn
}

output "grafana_fqdn" {
  description = "Public Grafana hostname used by the ingress resources."
  value       = local.grafana_fqdn
}

output "prometheus_fqdn" {
  description = "Public Prometheus hostname used by the ingress resources."
  value       = local.prometheus_fqdn
}

output "dns_zone" {
  description = "Primary DigitalOcean DNS zone managed by Terraform."
  value       = digitalocean_domain.primary.name
}

output "app_namespace" {
  description = "Namespace for the application services."
  value       = kubernetes_namespace_v1.app.metadata[0].name
}

output "monitoring_namespace" {
  description = "Namespace for monitoring workloads and dashboards."
  value       = kubernetes_namespace_v1.monitoring.metadata[0].name
}

output "cert_manager_namespace" {
  description = "Namespace where cert-manager is installed."
  value       = kubernetes_namespace_v1.cert_manager.metadata[0].name
}

output "spaces_bucket_name" {
  description = "DigitalOcean Spaces bucket used for listing images."
  value       = digitalocean_spaces_bucket.listing_images.name
}

output "spaces_access_key" {
  description = "Spaces access key ID for the listing service."
  value       = digitalocean_spaces_key.listing_service.access_key
  sensitive   = true
}

output "spaces_secret_key" {
  description = "Spaces secret key for the listing service."
  value       = digitalocean_spaces_key.listing_service.secret_key
  sensitive   = true
}

output "grafana_admin_password" {
  description = "Generated Grafana admin password when one is not supplied."
  value       = local.grafana_admin_password
  sensitive   = true
}

