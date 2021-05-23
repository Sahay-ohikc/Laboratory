module "gke" {
  source                     = "terraform-google-modules/kubernetes-engine/google"
  project_id                 = "okhab-education-25433"
  name                       = "gke-stud"
  region                     = "us-east1"
  zones                      = ["us-east1-d", "us-east1-b", "us-east1-c"]
  network                    = "zone53-network"
  subnetwork                 = "zone53-public-sub"
  ip_range_pods              = ""
  ip_range_services          = ""
  
  node_pools = [
    {
      name               = "default-node-pool"
      machine_type       = "e2-micro"
      node_locations     = "us-east1-d,us-east1-b,us-east1-c"
      min_count          = 1
      max_count          = 10
      local_ssd_count    = 0
      disk_size_gb       = 100
      disk_type          = "pd-standard"
      image_type         = "COS"
      auto_repair        = true
      auto_upgrade       = true
      service_account    = google_service_account.kube-serviz.email
      preemptible        = false
      initial_node_count = 1
    },
  ]
  depends_on = [google_compute_network.zone53, google_service_account.kube-serviz]
}

resource "kubernetes_deployment" "front" {
  metadata {
    name = "front"
    labels = {
      app  = "guestbook"
      tier = "frontend"
    }
  }
  spec {
    replicas = 3
    selector {
      match_labels = {
        app  = "guestbook"
        tier = "frontend"
      }
    }
    template {
      metadata {
        labels = {
          app  = "guestbook"
          tier = "frontend"
        }
      }
      spec {
        container {
          image = "gcr.io/google-samples/gb-frontend:v6"
          name  = "php-redis"
          port {
            container_port = 80
          }
          env {
              name  = "GET_HOSTS_FROM"
              value = "dns"
          }
          resources {
            requests {
              cpu    = "100m"
              memory = "100Mi"
            }     
          }
          liveness_probe {
            http_get {
              path = "/"
              port = 80
            }
            initial_delay_seconds = 30
            period_seconds        = 10
          }
          readiness_probe {
            http_get {
              path = "/"
              port = 80
            }
            initial_delay_seconds = 30
            period_seconds        = 10
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "frontservice" {
  metadata {
    name = "frontservice"
    labels = {
      app  = "guestbook"
      tier = "frontend"
    }
  }
  spec {
    selector = {
      app  = "guestbook"
      tier = "frontend"
    }
    port {
      port = 80
    }
    type = "LoadBalancer"
#    load_balancer_ip = google_compute_global_address.kube-front.address
  }
}

resource "kubernetes_deployment" "redis-master" {
  metadata {
    name = "redis-master"
    labels = {
      app  = "redis"
      tier = "backend"
      role = "master"
    }
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app  = "redis"
        tier = "backend"
        role = "master"
      }
    }
    template {
      metadata {
        labels = {
          app  = "redis"
          tier = "backend"
          role = "master"
        }
      }
      spec {
        container {
          image = "k8s.gcr.io/redis:e2e"
          name  = "master"
          port {
            container_port = 6379
          }
          resources {
            requests {
              cpu    = "100m"
              memory = "100Mi"
            }     
          }
          liveness_probe {
            tcp_socket {
              port = 6379
            }
            initial_delay_seconds = 30
            period_seconds        = 10
          }
          readiness_probe {
            tcp_socket {
              port = 6379
            }
            initial_delay_seconds = 30
            period_seconds        = 10
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "redis-master" {
  metadata {
    name = "redis-master"
    labels = {
      app  = "redis"
      tier = "backend"
      role = "master"
    }
  }
  spec {
    selector = {
      app  = "redis"
      tier = "backend"
      role = "master"
    }
    port {
      port = 6379
      target_port = 6379
    }
  }
}

resource "kubernetes_deployment" "redis-slave" {
  metadata {
    name = "redis-slave"
    labels = {
      app  = "redis"
      tier = "backend"
      role = "slave"
    }
  }
  spec {
    replicas = 2
    selector {
      match_labels = {
        app  = "redis"
        tier = "backend"
        role = "slave"
      }
    }
    template {
      metadata {
        labels = {
          app  = "redis"
          tier = "backend"
          role = "slave"
        }
      }
      spec {
        container {
          image = "gcr.io/google_samples/gb-redisslave:v1"
          name  = "slave"
          port {
            container_port = 6379
          }
          env {
            name  = "GET_HOSTS_FROM"
            value = "dns"
          }
          resources {
            requests {
              cpu    = "100m"
              memory = "100Mi"
            }     
          }
          liveness_probe {
            tcp_socket {
              port = 6379
            }
            initial_delay_seconds = 30
            period_seconds        = 10
          }
          readiness_probe {
            tcp_socket {
              port = 6379
            }
            initial_delay_seconds = 30
            period_seconds        = 10
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "redis-slave" {
  metadata {
    name = "redis-slave"
    labels = {
      app  = "redis"
      tier = "backend"
      role = "slave"
    }
  }
  spec {
    selector = {
      app  = "redis"
      tier = "backend"
      role = "slave"
    }
    port {
      port = 6379
    }
  }
}
