resource "kubernetes_namespace" "frontend" {
  metadata {
    name = "frontend"
  }
}

resource "helm_release" "frontend" {
  name = "frontend"
  namespace = kubernetes_namespace.frontend.metadata[0].name
  chart = "../charts/frontend"

  depends_on = [
    helm_release.backend
  ]

  values = [
    file("helm_config/frontend.yaml")
  ]
}