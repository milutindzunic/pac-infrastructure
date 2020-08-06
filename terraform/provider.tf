provider "kubernetes" {
  config_context = "minikube"
}

provider "helm" {
  kubernetes {
    config_context = "minikube"
  }
}