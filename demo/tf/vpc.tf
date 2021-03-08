resource "google_compute_network" "zone53" {
  name = "zone53-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "zone53-private" {
  name            = "zone53-private-sub"
  ip_cidr_range   = "10.53.10.0/24"
  region          = "us-east1"
  network         = google_compute_network.zone53.id
}

resource "google_compute_subnetwork" "zone53-public" {
  name            = "zone53-public-sub"
  ip_cidr_range   = "10.53.1.0/24"
  region          = "us-east1"
  network         = google_compute_network.zone53.id
}

resource "google_compute_firewall" "zone53-healthcheck" {
  name    = "zone53-healthcheck"
  network = google_compute_network.zone53.name

  allow {
    protocol = "all"
  }

  target_tags   = ["allow-health-check"]
  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
}

resource "google_compute_firewall" "zone53-network-allow-http" {
  name    = "zone53-network-allow-http"
  network = google_compute_network.zone53.name

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }
}

resource "google_compute_firewall" "zone53-network-allow-elk" {
  name    = "zone53-network-allow-sql-elastic"
  network = google_compute_network.zone53.name

  allow {
    protocol = "tcp"
    ports    = ["9200", "9300", "5044", "5601"]
  }
  source_ranges = ["10.53.0.0/16"]
}

resource "google_compute_firewall" "zone53-network-allow-sql" {
  name    = "zone53-network-allow-sql"
  network = google_compute_network.zone53.name

  allow {
    protocol = "tcp"
    ports    = ["1433"]
  }
  source_ranges = ["10.0.0.0/8"]
}

resource "google_compute_firewall" "zone53-network-allow-ssh" {
  name    = "zone53-network-allow-ssh"
  network = google_compute_network.zone53.name
  
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}

resource "google_compute_router" "zone53-router" {
  name    = "my-zone53-router"
  region  = "us-east1"
  network = google_compute_network.zone53.id
}

resource "google_compute_router_nat" "zone53-nat" {
  name                               = "my-zone53-nat"
  router                             = google_compute_router.zone53-router.name
  region                             = google_compute_router.zone53-router.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}
