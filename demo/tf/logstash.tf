resource "google_compute_instance" "logstash-tf-1" {
  name         = "logstash-tf-1"
  machine_type = "g1-small"
  zone         = "us-east1-b"

  tags = ["logstash", "elk"]

  boot_disk {
    initialize_params {
      image = "ubuntu-2004-focal-v20210223"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.zone53-private.id
    network_ip = "10.53.10.14"
  }

  service_account {
    email  = google_service_account.wp-service-account.email
    scopes = ["cloud-platform"]
  }
}

resource "google_compute_instance" "logstash-tf-2" {
  name         = "logstash-tf-2"
  machine_type = "g1-small"
  zone         = "us-east1-c"

  tags = ["logstash", "elk"]

  boot_disk {
    initialize_params {
      image = "ubuntu-2004-focal-v20210223"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.zone53-private.id
    network_ip = "10.53.10.15"
  }

  service_account {
    email  = google_service_account.wp-service-account.email
    scopes = ["cloud-platform"]
  }
}
