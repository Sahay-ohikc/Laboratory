#resource "google_compute_global_address" "bastion-ip" {
#  name = "bastion-ip1"
#}

resource "google_compute_instance" "bastion52" {
  name         = "bastion52"
  machine_type = "f1-micro"
  zone         = "us-east1-b"
  tags         = ["bastion", "public"]
  boot_disk {
    initialize_params {
      image = "family/ubuntu-2004-lts"
    }
  }
  network_interface {
    subnetwork = google_compute_subnetwork.zone52-public.id
    access_config {
      network_tier = "STANDARD"
    }
  }
  metadata = {
    ssh-keys = "${var.gce_ssh_user}:${file(var.gce_ssh_pub_key_file)}"
  }
  metadata_startup_script = "sudo apt-get install -y netcat | sudo sed -i 's/#Port 22/Port 7000/' /etc/ssh/sshd_config | sudo systemctl restart sshd"
}

resource "google_compute_firewall" "bastion52-ssh" {
  name    = "bastion52-ssh" 
  network = google_compute_network.zone52.name
  allow {
    protocol = "tcp"
    ports    = ["22", "7000"]
  }
  direction = "INGRESS"
  target_tags = ["bastion", "public", "private"]
}

resource "google_compute_firewall" "bastion52-http" {
  name    = "bastion52-http" 
  network = google_compute_network.zone52.name
  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
  direction = "INGRESS"
}

