resource "google_compute_instance" "bastion53" {
  name         = "bastion53"
  machine_type = "f1-micro"
  zone         = "us-east1-b"
  tags         = ["bastion", "public"]
  boot_disk {
    initialize_params {
      image = "ubuntu-minimal-2004-focal-v20210223a"
    }
  }
  network_interface {
    subnetwork = google_compute_subnetwork.zone53-public.id
    access_config {}
  }
}
