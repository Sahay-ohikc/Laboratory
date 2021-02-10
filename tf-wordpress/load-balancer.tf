resource "google_compute_forwarding_rule" "load-balancer-rule" {
  name                  = "wordpress-forwarding-rule"
  region                = "us-east1"
  ip_protocol           = "TCP"
  load_balancing_scheme = "INTERNAL_MANAGED"
  port_range            = "80"
  target                = "google_compute_region_target_http_proxy.http-proxy.id"
  network               = google_compute_network.zone53.id
  subnetwork            = google_compute_subnetwork.zone53-private.id
  network_tier          = "STANDARD"
  allow_global_access   = "true"
}

resource "google_compute_region_target_http_proxy" "http-proxy" {
  region  = "us-east1"
  name    = "wordpress-proxy"
  url_map = google_compute_region_url_map.default.id
}

resource "google_compute_region_url_map" "default" {
  region          = "us-east1"
  name            = "wordpress-map"
  default_service = google_compute_region_backend_service.wordpress-backend.id
}
  
resource "google_compute_region_backend_service" "wordpress-backend" {
  load_balancing_scheme = "INTERNAL_MANAGED"
  backend {
    group           = google_compute_region_instance_group_manager.wordpress-tf.instance_group
    balancing_mode  = "UTILIZATION"
    capacity_scaler = 1.0
  }
  region      = "us-east1"
  name        = "wordpress-backend"
  protocol    = "HTTP"
  timeout_sec = 10
  health_checks = [google_compute_health_check.autohealing.id]
}


