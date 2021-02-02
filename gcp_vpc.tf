resource "google_compute_network" "zone51" {
  name = "zone51-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "zone51-private" {
  name            = "zone51-private-sub"
  ip_cidr_range   = "10.51.1.0/24"
  region          = "europe-west3"
  network         = google_compute_network.zone51.id
}

resource "google_compute_subnetwork" "zone51-public" {
  name            = "zone51-public-sub"
  ip_cidr_range   = "10.51.2.0/24"
  region          = "europe-west3"
  network         = google_compute_network.zone51.id
}

resource "google_compute_router" "zone51-router" {
  name    = "my-zone51-router"
  region  = "europe-west3"
  network = google_compute_network.zone51.id
}

resource "google_compute_router_nat" "zone51-nat" {
  name                               = "my-zone51-nat"
  router                             = google_compute_router.zone51-router.name
  region                             = google_compute_router.zone51-router.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

#resource "google_compute_global_address" "bastion-ip" {
#  name = "bastion-ip1"
#}

resource "google_compute_instance" "bastion" {
  name         = "bastion1"
  machine_type = "f1-micro"
  zone         = "europe-west3-a"
  tags         = ["bastion", "public"]
  boot_disk {
    initialize_params {
      image = "ubuntu-minimal-2004-focal-v20210130"
    }
  }
  network_interface {
    subnetwork = google_compute_subnetwork.zone51-public.id
    access_config {}
  }
}

resource "google_compute_firewall" "bastion-ssh" {
  name    = "bastion-ssh" 
  network = google_compute_network.zone51.name
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  direction = "INGRESS"
  target_tags = ["bastion", "public"]
}

resource "google_compute_firewall" "bastion-7000" {
  name    = "bastion-7000" 
  network = google_compute_network.zone51.name
  allow {
    protocol = "tcp"
    ports    = ["7000"]
  }
  direction     = "INGRESS"
  target_tags   = ["bastion", "public"]
  source_ranges = ["10.51.1.0/24"] 
}
