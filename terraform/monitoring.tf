resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
  }
}

resource "random_password" "prometheus-password" {
  length = 16
  special = false
}

resource "kubernetes_secret" "prometheus-access" {
  metadata {
    name = "prometheus-access"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
  }

  data = {
    "grafana.adminUser" = "admin"
    "grafana.adminPassword" = random_password.prometheus-password.result
  }
}

resource "helm_release" "prometheus-operator" {
  name = "prometheus-operator"
  namespace = kubernetes_namespace.monitoring.metadata[0].name
  repository = local.helm_repository_stable
  chart = "prometheus-operator"

  values = [
    file("helm_config/prometheus-operator.yaml")
  ]

  set {
    name = "grafana.adminPassword"
    value = random_password.prometheus-password.result
  }
}