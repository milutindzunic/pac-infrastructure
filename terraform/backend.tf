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
    name = "keycloak-backend-access"
    namespace = kubernetes_namespace.backend.metadata[0].name
  }

  data = {
    # TODO
    username = "TODO"
    password = random_password.backend-mysql-password.result
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