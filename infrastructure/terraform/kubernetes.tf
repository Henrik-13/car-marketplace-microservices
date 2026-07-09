# Manage the cluster namespaces and sensitive Kubernetes secrets for the application stack.

locals {
  resolved_jwt_secret          = coalesce(var.jwt_secret, random_password.jwt_secret.result)
  resolved_user_db_password    = coalesce(var.user_db_password, random_password.user_db_password.result)
  resolved_listing_db_password = coalesce(var.listing_db_password, random_password.listing_db_password.result)
  resolved_cache_token         = coalesce(var.cache_auth_token, random_password.cache_auth_token.result)
}

resource "random_password" "jwt_secret" {
  length  = 48
  special = false
}

resource "random_password" "user_db_password" {
  length  = 24
  special = false
}

resource "random_password" "listing_db_password" {
  length  = 24
  special = false
}

resource "random_password" "cache_auth_token" {
  length  = 32
  special = false
}

resource "kubernetes_secret_v1" "user_service" {
  metadata {
    name      = "user-service-secrets"
    namespace = kubernetes_namespace_v1.app.metadata[0].name

    labels = {
      "app.kubernetes.io/name"      = "user-service"
      "app.kubernetes.io/part-of"   = "car-marketplace"
      "app.kubernetes.io/component" = "security"
    }
  }

  data = {
    JWT_SECRET  = local.resolved_jwt_secret
    DB_USERNAME = var.user_db_username
    DB_PASSWORD = local.resolved_user_db_password
    DB_URL      = "jdbc:postgresql://user-db.${kubernetes_namespace_v1.databases.metadata[0].name}.svc.cluster.local:5432/${var.user_db_name}"
    DB_HOST     = "user-db.${kubernetes_namespace_v1.databases.metadata[0].name}.svc.cluster.local"
    DB_PORT     = "5432"
    DB_NAME     = var.user_db_name
  }

  depends_on = [kubernetes_namespace_v1.app, kubernetes_namespace_v1.databases]
}

resource "kubernetes_secret_v1" "listing_service" {
  metadata {
    name      = "listing-service-secrets"
    namespace = kubernetes_namespace_v1.app.metadata[0].name

    labels = {
      "app.kubernetes.io/name"      = "listing-service"
      "app.kubernetes.io/part-of"   = "car-marketplace"
      "app.kubernetes.io/component" = "security"
    }
  }

  data = {
    DB_USERNAME     = var.listing_db_username
    DB_PASSWORD     = local.resolved_listing_db_password
    DB_URL          = "jdbc:postgresql://listing-db.${kubernetes_namespace_v1.databases.metadata[0].name}.svc.cluster.local:5432/${var.listing_db_name}"
    DB_HOST         = "listing-db.${kubernetes_namespace_v1.databases.metadata[0].name}.svc.cluster.local"
    DB_PORT         = "5432"
    DB_NAME         = var.listing_db_name
    S3_ACCESS_KEY   = digitalocean_spaces_key.listing_service.access_key
    S3_SECRET_KEY   = digitalocean_spaces_key.listing_service.secret_key
    S3_BUCKET_NAME  = digitalocean_spaces_bucket.listing_images.name
    S3_ENDPOINT_URL = "https://${var.spaces_region}.digitaloceanspaces.com"
  }

  depends_on = [kubernetes_namespace_v1.app, kubernetes_namespace_v1.databases, digitalocean_spaces_key.listing_service]
}

resource "kubernetes_secret_v1" "prediction_service" {
  metadata {
    name      = "prediction-service-secrets"
    namespace = kubernetes_namespace_v1.app.metadata[0].name

    labels = {
      "app.kubernetes.io/name"      = "prediction-service"
      "app.kubernetes.io/part-of"   = "car-marketplace"
      "app.kubernetes.io/component" = "configuration"
    }
  }

  data = {
    MODEL_EXPORT_DIR = "/app/export"
  }

  depends_on = [kubernetes_namespace_v1.app]
}

resource "kubernetes_secret_v1" "cache_service" {
  metadata {
    name      = "cache-service-secrets"
    namespace = kubernetes_namespace_v1.app.metadata[0].name

    labels = {
      "app.kubernetes.io/name"      = "cache-service"
      "app.kubernetes.io/part-of"   = "car-marketplace"
      "app.kubernetes.io/component" = "security"
    }
  }

  data = {
    CACHE_AUTH_TOKEN = local.resolved_cache_token
  }

  depends_on = [kubernetes_namespace_v1.app]
}

resource "kubernetes_secret_v1" "user_db" {
  metadata {
    name      = "user-db-credentials"
    namespace = kubernetes_namespace_v1.databases.metadata[0].name

    labels = {
      "app.kubernetes.io/name"      = "user-db"
      "app.kubernetes.io/part-of"   = "car-marketplace"
      "app.kubernetes.io/component" = "database"
    }
  }

  data = {
    POSTGRES_USER     = var.user_db_username
    POSTGRES_PASSWORD = local.resolved_user_db_password
    POSTGRES_DB       = var.user_db_name
  }

  depends_on = [kubernetes_namespace_v1.databases]
}

resource "kubernetes_secret_v1" "listing_db" {
  metadata {
    name      = "listing-db-credentials"
    namespace = kubernetes_namespace_v1.databases.metadata[0].name

    labels = {
      "app.kubernetes.io/name"      = "listing-db"
      "app.kubernetes.io/part-of"   = "car-marketplace"
      "app.kubernetes.io/component" = "database"
    }
  }

  data = {
    POSTGRES_USER     = var.listing_db_username
    POSTGRES_PASSWORD = local.resolved_listing_db_password
    POSTGRES_DB       = var.listing_db_name
  }

  depends_on = [kubernetes_namespace_v1.databases]
}
