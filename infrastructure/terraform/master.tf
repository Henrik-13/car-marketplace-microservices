# Generate the shared join token once so both K3s nodes bootstrap against the same secret.
resource "random_password" "k3s_token" {
  length  = var.k3s_token_length
  special = false
  upper   = false
}

# Provision the K3s master node and bootstrap the server with cloud-init.
resource "digitalocean_droplet" "master" {
  name   = "${var.name_prefix}-master"
  region = var.region
  size   = var.size
  image  = var.image

  vpc_uuid = digitalocean_vpc.k3s.id
  tags     = var.tags

  user_data = templatefile("${path.module}/cloud-init/master.yaml", {
    ssh_public_key = var.ssh_public_key
    k3s_token      = random_password.k3s_token.result
    k3s_version    = var.k3s_version
    floating_ip    = digitalocean_floating_ip.master.ip_address
  })
}
