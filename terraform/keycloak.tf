resource "kubernetes_namespace" "keycloak" {
  metadata {
    name = "keycloak"
  }
}

resource "random_password" "keycloak-mysql-password" {
  length = 16
  special = false
}

resource "random_password" "keycloak-user-password" {
  length = 16
  special = false
}

resource "kubernetes_secret" "keycloak-mysql-access" {
  metadata {
    name = "keycloak-mysql-access"
    namespace = kubernetes_namespace.keycloak.metadata[0].name
  }

  data = {
    username = "keycloak"
    password = random_password.keycloak-mysql-password.result
  }
}

resource "kubernetes_secret" "keycloak-access" {
  metadata {
    name = "keycloak-access"
    namespace = kubernetes_namespace.keycloak.metadata[0].name
  }

  data = {
    "password" = random_password.keycloak-user-password.result
  }
}

resource "helm_release" "keycloak-mysql" {
  name = "keycloak-mysql"
  namespace = kubernetes_namespace.keycloak.metadata[0].name
  chart = "mysql"
  repository = local.helm_repository_bitnami

  values = [
    file("helm_config/keycloak-mysql.yaml")
  ]

  set {
    name = "db.password"
    value = random_password.keycloak-mysql-password.result
  }
}

resource "kubernetes_secret" "realm-secret" {
  metadata {
    name = "realm-secret"
    namespace = kubernetes_namespace.keycloak.metadata[0].name
  }

  data = {
    "realm.json" = file("helm_config/keycloak/realm-export.json")
  }
}

resource "helm_release" "keycloak" {
  name = "keycloak"
  namespace = kubernetes_namespace.keycloak.metadata[0].name
  chart = "keycloak"
  version = "8.3.0"
  repository = local.helm_repository_codecentric

  depends_on = [
    helm_release.keycloak-mysql,
    kubernetes_secret.realm-secret
  ]

  values = [
    file("helm_config/keycloak.yaml")
  ]
}