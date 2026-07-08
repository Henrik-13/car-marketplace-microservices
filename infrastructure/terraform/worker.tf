# Provision the K3s worker node and have cloud-init join it to the master automatically.
resource "digitalocean_droplet" "worker" {
  name   = "${var.name_prefix}-worker"
  region = var.region
  size   = var.size
  image  = var.image

  vpc_uuid = digitalocean_vpc.k3s.id
  tags     = var.tags

  user_data = templatefile("${path.module}/cloud-init/worker.yaml", {
    ssh_public_key    = var.ssh_public_key
    k3s_token         = random_password.k3s_token.result
    k3s_version       = var.k3s_version
    master_private_ip = digitalocean_droplet.master.ipv4_address_private
  })
}
