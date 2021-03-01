resource "google_compute_instance" "esearch-tf-1" {
  name         = "esearch-tf-1"
  machine_type = "e2-small"
  zone         = "us-east1-b"

  tags = ["esearch", "elk"]

  boot_disk {
    initialize_params {
      image = "ubuntu-2004-focal-v20210211"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.zone53-private.id
    network_ip = "10.53.10.20"
  }

  service_account {
    email  = google_service_account.wp-service-account.email
    scopes = ["cloud-platform"]
  }
}

resource "google_compute_instance" "esearch-tf-2" {
  name         = "esearch-tf-2"
  machine_type = "e2-small"
  zone         = "us-east1-c"

  tags = ["esearch", "elk"]

  boot_disk {
    initialize_params {
      image = "ubuntu-2004-focal-v20210211"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.zone53-private.id
    network_ip = "10.53.10.18"
  }

  service_account {
    email  = google_service_account.wp-service-account.email
    scopes = ["cloud-platform"]
  }
}

resource "google_compute_instance" "esearch-tf-3" {
  name         = "esearch-tf-3"
  machine_type = "e2-small"
  zone         = "us-east1-d"

  tags = ["esearch", "elk"]

  boot_disk {
    initialize_params {
      image = "ubuntu-2004-focal-v20210211"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.zone53-private.id
    network_ip = "10.53.10.19"
  }

  service_account {
    email  = google_service_account.wp-service-account.email
    scopes = ["cloud-platform"]
  }
}
