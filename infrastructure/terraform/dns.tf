# # Create the public DNS zone and point the application subdomains at the master's floating IP.
# resource "digitalocean_domain" "primary" {
#   name = var.domain_name
# }

# locals {
#   api_fqdn         = "${var.api_subdomain}.${var.domain_name}"
#   grafana_fqdn     = "${var.grafana_subdomain}.${var.domain_name}"
#   prometheus_fqdn  = "${var.prometheus_subdomain}.${var.domain_name}"
#   api_tls_secret   = "${replace(local.api_fqdn, ".", "-")}-tls"
#   grafana_tls_name = "${replace(local.grafana_fqdn, ".", "-")}-tls"
#   prom_tls_name    = "${replace(local.prometheus_fqdn, ".", "-")}-tls"
# }

# resource "digitalocean_record" "api" {
#   domain = digitalocean_domain.primary.id
#   type   = "A"
#   name   = var.api_subdomain
#   value  = digitalocean_floating_ip.master.ip_address
#   ttl    = 300
# }

# resource "digitalocean_record" "grafana" {
#   domain = digitalocean_domain.primary.id
#   type   = "A"
#   name   = var.grafana_subdomain
#   value  = digitalocean_floating_ip.master.ip_address
#   ttl    = 300
# }

# resource "digitalocean_record" "prometheus" {
#   domain = digitalocean_domain.primary.id
#   type   = "A"
#   name   = var.prometheus_subdomain
#   value  = digitalocean_floating_ip.master.ip_address
#   ttl    = 300
# }
