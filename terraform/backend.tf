resource "kubernetes_namespace" "backend" {
  metadata {
    name = "backend"
  }
}

resource "random_password" "backend-mysql-password" {
  length = 16
  special = false
}

resource "kubernetes_secret" "backend-mysql-access" {
  metadata {
    name = "backend-mysql-access"
    namespace = kubernetes_namespace.backend.metadata[0].name
  }

  data = {
    DB_USER = "backend"
    DB_PASSWORD = random_password.backend-mysql-password.result
  }
}

resource "helm_release" "backend-mysql" {
  name = "backend-mysql"
  namespace = kubernetes_namespace.backend.metadata[0].name
  chart = "mysql"
  repository = local.helm_repository_bitnami

  values = [
    file("helm_config/backend-mysql.yaml")
  ]

  set {
    name = "db.password"
    value = random_password.backend-mysql-password.result
  }
}

resource "kubernetes_config_map" "backend-config" {
  metadata {
    name = "backend-config"
    namespace = kubernetes_namespace.backend.metadata[0].name
  }

  data = {
    BIND_ADDRESS = ":80"
    DB_DRIVER = "mysql"
    DB_HOST = helm_release.backend-mysql.metadata[0].name
    DB_PORT = "3306"
    DB_NAME = "backend"
  }
}

resource "helm_release" "backend" {
  name = "backend"
  namespace = kubernetes_namespace.backend.metadata[0].name
  chart = "../charts/backend"

  depends_on = [
    helm_release.backend-mysql,
    kubernetes_config_map.backend-config,
    kubernetes_secret.backend-mysql-access
  ]

  values = [
    file("helm_config/backend.yaml")
  ]
}