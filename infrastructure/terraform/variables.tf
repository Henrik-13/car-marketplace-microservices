variable "do_token" {
  description = "DigitalOcean API token used by the Terraform provider."
  type        = string
  sensitive   = true
}

variable "ssh_public_key" {
  description = "SSH public key that cloud-init installs on both droplets for administrative access."
  type        = string
}

variable "project_name" {
  description = "Human-readable name used for the Terraform-managed infrastructure."
  type        = string
  default     = "car-marketplace-phase-3"
}

variable "name_prefix" {
  description = "Prefix applied to all DigitalOcean resource names."
  type        = string
  default     = "car-marketplace"
}

variable "region" {
  description = "DigitalOcean region where the K3s cluster is provisioned."
  type        = string
  default     = "fra1"
}

variable "size" {
  description = "Droplet size for both cluster nodes."
  type        = string
  default     = "s-2vcpu-4gb"
}

variable "image" {
  description = "Ubuntu image slug used for the droplets."
  type        = string
  default     = "ubuntu-24-04-x64"
}

variable "vpc_cidr" {
  description = "CIDR block used for the dedicated private VPC network."
  type        = string
  default     = "10.20.0.0/16"
}

variable "k3s_version" {
  description = "Optional pinned K3s version. Leave empty to use the stable install channel."
  type        = string
  default     = ""
}

variable "k3s_token_length" {
  description = "Length of the generated K3s cluster join token."
  type        = number
  default     = 48
}

variable "tags" {
  description = "Tags applied to all droplets so they are easy to identify in the DigitalOcean control plane."
  type        = list(string)
  default     = ["car-marketplace", "phase-1", "k3s"]
}

variable "domain_name" {
  description = "Primary DNS zone used for public application hostnames."
  type        = string
  default     = "example.com"
}

variable "api_subdomain" {
  description = "Public hostname prefix for the API ingress."
  type        = string
  default     = "api"
}

variable "grafana_subdomain" {
  description = "Public hostname prefix for Grafana."
  type        = string
  default     = "grafana"
}

variable "prometheus_subdomain" {
  description = "Public hostname prefix for Prometheus."
  type        = string
  default     = "prometheus"
}

variable "letsencrypt_email" {
  description = "Email address used for the Let's Encrypt production ClusterIssuer."
  type        = string
}

variable "spaces_endpoint" {
  description = "DigitalOcean Spaces API endpoint for the configured region."
  type        = string
  default     = "https://fra1.digitaloceanspaces.com"
}

variable "kubeconfig_path" {
  description = "Path to the kubeconfig file that Terraform uses to connect to the K3s cluster."
  type        = string
  default     = "~/.kube/config"
}

variable "kubeconfig_context" {
  description = "Optional kubeconfig context name. Leave empty to use the current context."
  type        = string
  default     = null
}

variable "cert_manager_namespace" {
  description = "Namespace where cert-manager is installed."
  type        = string
  default     = "cert-manager"
}

variable "app_namespace" {
  description = "Namespace for the application services and ingresses."
  type        = string
  default     = "car-marketplace"
}

variable "monitoring_namespace" {
  description = "Namespace for monitoring workloads and public dashboards."
  type        = string
  default     = "monitoring"
}

variable "database_namespace" {
  description = "Namespace for PostgreSQL workloads."
  type        = string
  default     = "databases"
}

variable "storage_namespace" {
  description = "Namespace for storage-related Kubernetes secrets and helper resources."
  type        = string
  default     = "storage"
}

variable "traefik_ingress_class_name" {
  description = "IngressClass name used by the built-in Traefik controller."
  type        = string
  default     = "traefik"
}

variable "cert_manager_chart_version" {
  description = "Pinned cert-manager chart version for reproducible Helm installs."
  type        = string
  default     = "v1.15.3"
}

variable "app_image" {
  description = "Container image for the user-service deployment."
  type        = string
}

variable "listing_image" {
  description = "Container image for the listing-service deployment."
  type        = string
}

variable "prediction_image" {
  description = "Container image for the prediction-service deployment."
  type        = string
}

variable "cache_image" {
  description = "Container image for the cache-service deployment."
  type        = string
}

variable "app_replicas_user" {
  description = "Replica count for the user-service deployment."
  type        = number
  default     = 2
}

variable "app_replicas_listing" {
  description = "Replica count for the listing-service deployment."
  type        = number
  default     = 2
}

variable "app_replicas_prediction" {
  description = "Replica count for the prediction-service deployment."
  type        = number
  default     = 1
}

variable "app_replicas_cache" {
  description = "Replica count for the cache-service deployment."
  type        = number
  default     = 1
}

variable "app_resource_requests_cpu" {
  description = "Default CPU request for application containers."
  type        = string
  default     = "100m"
}

variable "app_resource_limits_cpu" {
  description = "Default CPU limit for application containers."
  type        = string
  default     = "1000m"
}

variable "app_resource_requests_memory" {
  description = "Default memory request for application containers."
  type        = string
  default     = "256Mi"
}

variable "app_resource_limits_memory" {
  description = "Default memory limit for application containers."
  type        = string
  default     = "2Gi"
}

variable "postgres_resource_requests_cpu" {
  description = "CPU request for PostgreSQL containers."
  type        = string
  default     = "100m"
}

variable "postgres_resource_limits_cpu" {
  description = "CPU limit for PostgreSQL containers."
  type        = string
  default     = "500m"
}

variable "postgres_resource_requests_memory" {
  description = "Memory request for PostgreSQL containers."
  type        = string
  default     = "256Mi"
}

variable "postgres_resource_limits_memory" {
  description = "Memory limit for PostgreSQL containers."
  type        = string
  default     = "1Gi"
}

variable "prediction_model_path" {
  description = "Path to the mounted prediction model artifacts."
  type        = string
  default     = "/app/export"
}

variable "prediction_cache_host" {
  description = "Host used by prediction-service for cache access."
  type        = string
  default     = "cache-service"
}

variable "prediction_cache_port" {
  description = "Port used by prediction-service for cache access."
  type        = number
  default     = 6379
}

variable "prediction_api_port" {
  description = "Port exposed by the prediction-service container."
  type        = number
  default     = 8083
}

variable "cache_port" {
  description = "Port exposed by the cache-service container."
  type        = number
  default     = 6379
}

variable "jwt_secret" {
  description = "JWT signing secret shared by user-service and listing-service."
  type        = string
  sensitive   = true
}

variable "prediction_service_url_internal" {
  description = "Internal URL used by listing-service to call prediction-service."
  type        = string
  default     = "http://prediction-service.car-marketplace.svc.cluster.local:8083/predict"
}

variable "spaces_region" {
  description = "DigitalOcean Spaces region used for the listing-service image bucket."
  type        = string
  default     = "fra1"
}

variable "spaces_bucket_name" {
  description = "Name of the DigitalOcean Spaces bucket used for listing images."
  type        = string
  default     = "car-marketplace-images"
}

variable "spaces_access_id" {
  description = "Spaces access key ID used by Terraform to create bucket resources."
  type        = string
  sensitive   = true
}

variable "spaces_secret_key" {
  description = "Spaces secret access key used by Terraform to create bucket resources."
  type        = string
  sensitive   = true
}

# variable "user_service_jwt_secret" {
#   description = "JWT signing secret used by the user-service. Leave empty to generate one."
#   type        = string
#   default     = null
#   sensitive   = true
# }

variable "user_db_username" {
  description = "Database username used by user-service and user-db."
  type        = string
  default     = "user"
}

variable "user_db_password" {
  description = "Database password used by user-service and user-db. Leave empty to generate one."
  type        = string
  default     = null
  sensitive   = true
}

variable "user_db_name" {
  description = "Database name used by the user-service PostgreSQL instance."
  type        = string
  default     = "userdb"
}

variable "listing_db_username" {
  description = "Database username used by listing-service and listing-db."
  type        = string
  default     = "listing"
}

variable "listing_db_password" {
  description = "Database password used by listing-service and listing-db. Leave empty to generate one."
  type        = string
  default     = null
  sensitive   = true
}

variable "listing_db_name" {
  description = "Database name used by the listing-service PostgreSQL instance."
  type        = string
  default     = "listingdb"
}

variable "cache_auth_token" {
  description = "Optional authentication token for the cache-service. Leave empty to generate one."
  type        = string
  default     = null
  sensitive   = true
}

variable "user_service_image" {
  description = "Container image for the user-service deployment."
  type        = string
  default     = "ghcr.io/car-marketplace/user-service:latest"
}

variable "listing_service_image" {
  description = "Container image for the listing-service deployment."
  type        = string
  default     = "ghcr.io/car-marketplace/listing-service:latest"
}

variable "prediction_service_image" {
  description = "Container image for the prediction-service deployment."
  type        = string
  default     = "ghcr.io/car-marketplace/prediction-service:latest"
}

variable "cache_service_image" {
  description = "Container image for the cache-service deployment."
  type        = string
  default     = "ghcr.io/car-marketplace/cache-service:latest"
}

variable "postgres_image" {
  description = "PostgreSQL container image used for both database workloads."
  type        = string
  default     = "postgres:16-alpine"
}

variable "user_service_replicas" {
  description = "Replica count for the user-service deployment."
  type        = number
  default     = 2
}

variable "listing_service_replicas" {
  description = "Replica count for the listing-service deployment."
  type        = number
  default     = 2
}

variable "prediction_service_replicas" {
  description = "Replica count for the prediction-service deployment."
  type        = number
  default     = 1
}

variable "cache_service_replicas" {
  description = "Replica count for the cache-service deployment."
  type        = number
  default     = 1
}

variable "resource_cpu_request" {
  description = "Default CPU request for application containers."
  type        = string
  default     = "100m"
}

variable "resource_cpu_limit" {
  description = "Default CPU limit for application containers."
  type        = string
  default     = "1000m"
}

variable "resource_memory_request" {
  description = "Default memory request for application containers."
  type        = string
  default     = "256Mi"
}

variable "resource_memory_limit" {
  description = "Default memory limit for application containers."
  type        = string
  default     = "2Gi"
}

variable "postgres_storage_size" {
  description = "Persistent volume size for PostgreSQL workloads."
  type        = string
  default     = "10Gi"
}

variable "cache_storage_size" {
  description = "Optional persistent volume size for cache-service data."
  type        = string
  default     = "1Gi"
}

variable "grafana_admin_password" {
  description = "Grafana admin password for the monitoring stack. Leave empty to generate one."
  type        = string
  default     = null
  sensitive   = true
}

