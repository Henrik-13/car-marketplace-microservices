# Create the Spaces bucket that stores listing-service uploads and grant the application a scoped access key.
resource "digitalocean_spaces_bucket" "listing_images" {
  name          = var.spaces_bucket_name
  region        = var.spaces_region
  acl           = "private"
  force_destroy = true
}

resource "digitalocean_spaces_key" "listing_service" {
  name = "${var.name_prefix}-listing-service-spaces"

  grant {
    bucket     = digitalocean_spaces_bucket.listing_images.name
    permission = "readwrite"
  }

  depends_on = [digitalocean_spaces_bucket.listing_images]
}