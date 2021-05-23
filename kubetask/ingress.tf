resource "kubernetes_ingress" "ingresstroller" {
  metadata {
    name = "ingresstroller"
  }

  spec {
    backend {
      service_name = "frontservice"
      service_port = 80
    }
  }
}

