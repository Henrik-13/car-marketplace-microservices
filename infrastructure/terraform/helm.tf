# Create the namespaces that will host the application, monitoring, and certificate-management resources.
resource "kubernetes_namespace_v1" "app" {
  metadata {
    name = var.app_namespace

    labels = {
      "app.kubernetes.io/part-of" = "car-marketplace"
      "environment"               = "production"
    }
  }
}

resource "kubernetes_namespace_v1" "monitoring" {
  metadata {
    name = var.monitoring_namespace

    labels = {
      "app.kubernetes.io/part-of" = "car-marketplace"
      "component"                 = "monitoring"
    }
  }
}

resource "kubernetes_namespace_v1" "databases" {
  metadata {
    name = var.database_namespace

    labels = {
      "app.kubernetes.io/part-of" = "car-marketplace"
      "component"                 = "databases"
    }
  }
}

resource "kubernetes_namespace_v1" "storage" {
  metadata {
    name = var.storage_namespace

    labels = {
      "app.kubernetes.io/part-of" = "car-marketplace"
      "component"                 = "storage"
    }
  }
}

resource "kubernetes_namespace_v1" "cert_manager" {
  metadata {
    name = var.cert_manager_namespace

    labels = {
      "app.kubernetes.io/name" = "cert-manager"
    }
  }
}

# Install cert-manager with CRDs so ClusterIssuer and Certificate resources can be managed declaratively.
resource "helm_release" "cert_manager" {
  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  version          = var.cert_manager_chart_version
  namespace        = kubernetes_namespace_v1.cert_manager.metadata[0].name
  create_namespace = false
  wait             = true
  timeout          = 600
  atomic           = true

  values = [file("${path.module}/../helm/cert-manager/values.yaml")]

  depends_on = [kubernetes_namespace_v1.cert_manager]
}

resource "random_password" "grafana_admin_password" {
  length  = 24
  special = true
}

locals {
  grafana_admin_password = coalesce(var.grafana_admin_password, random_password.grafana_admin_password.result)
}

resource "helm_release" "grafana" {
  name             = "grafana"
  repository       = "https://grafana.github.io/helm-charts"
  chart            = "grafana"
  namespace        = kubernetes_namespace_v1.monitoring.metadata[0].name
  create_namespace = false
  wait             = true
  timeout          = 900
  atomic           = true

  set {
    name  = "fullnameOverride"
    value = "grafana"
  }

  set {
    name  = "service.type"
    value = "ClusterIP"
  }

  set {
    name  = "ingress.enabled"
    value = "false"
  }

  set_sensitive {
    name  = "adminPassword"
    value = local.grafana_admin_password
  }

  depends_on = [kubernetes_namespace_v1.monitoring]
}

resource "helm_release" "prometheus" {
  name             = "prometheus"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "prometheus"
  namespace        = kubernetes_namespace_v1.monitoring.metadata[0].name
  create_namespace = false
  wait             = true
  timeout          = 900
  atomic           = true

  set {
    name  = "server.service.type"
    value = "ClusterIP"
  }

  set {
    name  = "server.persistentVolume.enabled"
    value = "true"
  }

  set {
    name  = "server.persistentVolume.size"
    value = "2Gi"
  }

  depends_on = [kubernetes_namespace_v1.monitoring]
}
