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
    database = "keycloak"
    password = random_password.keycloak-mysql-password.result
  }
}

resource "kubernetes_secret" "keycloak-user-access" {

  metadata {
    name = "keycloak-user-access"
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
  repository = data.helm_repository.bitnami.url

  values = [
    file("helm_config/keycloak-mysql.yaml")
  ]

  set {
    name = "db.password"
    value = random_password.keycloak-mysql-password.result
  }

}

resource "helm_release" "keycloak" {

  depends_on = [
    helm_release.keycloak-mysql
  ]

  name = "keycloak"
  namespace = kubernetes_namespace.keycloak.metadata[0].name
  chart = "keycloak"
  repository = data.helm_repository.codecentric.url

  values = [
    file("helm_config/keycloak.yaml")
  ]
}