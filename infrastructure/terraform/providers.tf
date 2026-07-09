provider "digitalocean" {
  token             = var.do_token
  spaces_access_id  = var.spaces_access_id
  spaces_secret_key = var.spaces_secret_key
  spaces_endpoint   = var.spaces_endpoint
}

# provider "kubernetes" {
#   config_path    = pathexpand(var.kubeconfig_path)
#   config_context = var.kubeconfig_context
#   insecure       = true
# }

# provider "helm" {
#   kubernetes {
#     config_path    = pathexpand(var.kubeconfig_path)
#     config_context = var.kubeconfig_context
#     insecure       = true
#   }
# }

provider "kubernetes" {
  config_path = "~/.kube/config"
  insecure    = true
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
    insecure    = true
  }
}
