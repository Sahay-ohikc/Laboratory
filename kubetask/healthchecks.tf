resource "google_compute_health_check" "http-healthcheck" {
  name = "http-healthcheck"

  timeout_sec        = 5
  check_interval_sec = 10

  http_health_check {
    port = 80
    host = kubernetes_service.frontservice.spec.0.load_balancer_ip
  }
}

