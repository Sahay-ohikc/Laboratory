resource "google_compute_instance" "workhorse" {
  name         = "workhorse"
  machine_type = "f1-micro"
  zone         = "us-east1-b"
  tags         = ["workhorse", "private"]
  boot_disk {
    initialize_params {
      image = "family/ubuntu-2004-lts"
    }
  }
  network_interface {
    subnetwork = google_compute_subnetwork.zone52-private2.id
    network_ip = "10.52.2.20"
  }
  metadata = {
    ssh-keys = "${var.gce_ssh_user}:${file(var.gce_ssh_pub_key_file)}"
  }
}

resource "google_compute_firewall" "workhorse-rules" {
  name    = "workhorse-rules"
  network = google_compute_network.zone52.name
  allow {
    protocol = "tcp"
    ports    = ["8080"]
  }
  direction = "INGRESS"
}