resource "google_service_account" "wp-service-account" {
  account_id   = "wp-service"
}

resource "google_compute_instance_template" "wordpress-template-5" {
  name        = "wordpress-template"
  tags = ["wordpress", "private"]
  machine_type         = "f1-micro"
  can_ip_forward       = false

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
  }

  disk {
    source_image = "wordpress-image-1"
    auto_delete  = true
    boot         = true
  }

  network_interface {
    subnetwork = google_compute_subnetwork.zone53-private.id
  }

  metadata = {
    startup-script = "gcsfuse -o allow_other wp-bucket1 /var/www"
  }

  service_account {
    email  = google_service_account.wp-service-account.email
    scopes = ["cloud-platform"]
  }
}

resource "google_compute_health_check" "autohealing" {
  name                = "autohealing-health-check"
  check_interval_sec  = 10
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 4 

  tcp_health_check {
    port = "80"
  }
}

resource "google_compute_region_autoscaler" "wordpress-autoscaler" {
  name   = "wordpress-autoscaler"
  region = "us-east1"
  target = google_compute_region_instance_group_manager.wordpress-tf.id
  autoscaling_policy {
    max_replicas    = 5
    min_replicas    = 1
    cooldown_period = 60
    cpu_utilization { target = 0.8 }
  }
}

resource "google_compute_region_instance_group_manager" "wordpress-tf" {
  name = "wordpress-tf-group"

  base_instance_name         = "wordpress"
  region                     = "us-east1"
  distribution_policy_zones  = ["us-east1-b", "us-east1-c", "us-east1-d"]

  version {
    instance_template  = google_compute_instance_template.wordpress-template-5.id
  }

  #target_pools = [google_compute_target_pool.wordpress-tf.id]
  #target_size  = 1

  named_port {
    name = "http"
    port = 80
  }

  auto_healing_policies {
    health_check      = google_compute_health_check.autohealing.id
    initial_delay_sec = 300
  }
}
