# Create a dedicated private VPC so the K3s control plane and worker traffic stay isolated from the public internet.
resource "digitalocean_vpc" "k3s" {
  name        = "${var.name_prefix}-vpc"
  region      = var.region
  ip_range    = var.vpc_cidr
  description = "Private VPC for the car marketplace K3s cluster"
}
