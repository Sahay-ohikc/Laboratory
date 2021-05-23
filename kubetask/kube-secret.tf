resource "kubernetes_secret" "serviz" {
  metadata {
    name = "serviz"
    annotations = {
      "kubernetes.io/service-account.name" = google_service_account.kube-serviz.name  
    }
  }

  type = "kubernetes.io/service-account-token"
}
