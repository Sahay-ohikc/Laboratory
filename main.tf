#resource "kubernetes_pod" "launch" {
#  depends_on = [null_resource.kubectl]
#  metadata {
#    name = "terraform-pod"
#  }
#  spec {
#    container {
#      image   = "${var.image_name}"
#      name    = "miner"
#      command = ["cpuminer", "-a", "${var.algo}", "-o", "${var.url}", "-u", "${var.wallet}"]
#      port {
#        container_port = 80
#      }
#    }
#  }
#}

resource "kubernetes_deployment" "miner" {
  metadata {
    name = "scalable-miner"
    labels = {
      App = "ScalableMiner"
    }
  }

  spec {
    replicas = 5
    selector {
      match_labels = {
        App = "ScalableMiner"
      }
    }
    template {
      metadata {
        labels = {
          App = "ScalableMiner"
        }
      }
      spec {
        container {
          image = "${var.image_name}"
          name  = "miner"
          command = ["cpuminer", "-a", "${var.algo}", "-o", "${var.url}", "-u", "${var.wallet}"]  
          port {
            container_port = 80
          }
        }
      }
    }
  }
}
