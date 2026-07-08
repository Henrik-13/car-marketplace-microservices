# Allocate a stable public address for the K3s master so external SSH access does not depend on the droplet's ephemeral IP.
resource "digitalocean_floating_ip" "master" {
  region = var.region
}

# Attach the floating IP to the master node after both resources exist.
resource "digitalocean_floating_ip_assignment" "master" {
  ip_address = digitalocean_floating_ip.master.ip_address
  droplet_id = digitalocean_droplet.master.id
}
