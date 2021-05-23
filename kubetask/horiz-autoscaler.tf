resource "kubernetes_horizontal_pod_autoscaler" "gke-scaler" {
  metadata {
    name = "gke-scaler"
  }

  spec {
    min_replicas = 1
    max_replicas = 5

    scale_target_ref {
      kind = "Deployment"
      name = kubernetes_deployment.front.metadata.0.name
    }

#    metric {
#      type = "External"
#      external {
#        metric {
#          name = "latency"
#          selector {
#            match_labels = {
#              lb_name = "frontservice"
#            }
#          }
#        }
#        target {
#          type  = "Value"
#          value = "100"
#        }
#      }
#    }
  }
}
