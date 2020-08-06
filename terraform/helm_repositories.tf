data "helm_repository" "codecentric" {
  name = "codecentric"
  url = "https://codecentric.github.io/helm-charts"
}

data "helm_repository" "bitnami" {
  name = "bitnami"
  url = "https://charts.bitnami.com/bitnami"
}

data "helm_repository" "stable" {
  name = "stable"
  url = "https://kubernetes-charts.storage.googleapis.com"
}
