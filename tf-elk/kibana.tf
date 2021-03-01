resource "google_compute_instance" "kibana-tf" {
  name         = "kibana-tf"
  machine_type = "f1-micro"
  zone         = "us-east1-b"

  tags = ["kibana", "elk"]

  boot_disk {
    initialize_params {
      image = "ubuntu-2004-focal-v20210211"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.zone53-public.id
    network_ip = "10.53.1.30"
    access_config {
      network_tier = "STANDARD"
    }
    
  }

  service_account {
    email  = google_service_account.wp-service-account.email
    scopes = ["cloud-platform"]
  }
}


