resource "google_compute_network" "zone52" {
  name = "zone52-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "zone52-private2" {
  name            = "zone52-private2-sub"
  ip_cidr_range   = "10.52.2.0/24"
  region          = "us-east1"
  network         = google_compute_network.zone52.id
}

resource "google_compute_subnetwork" "zone52-private3" {
  name            = "zone52-private3-sub"
  ip_cidr_range   = "10.52.3.0/24"
  region          = "us-east1"
  network         = google_compute_network.zone52.id
}

resource "google_compute_subnetwork" "zone52-public" {
  name            = "zone52-public-sub"
  ip_cidr_range   = "10.52.1.0/24"
  region          = "us-east1"
  network         = google_compute_network.zone52.id
}

resource "google_compute_router" "zone52-router" {
  name    = "my-zone52-router"
  region  = "us-east1"
  network = google_compute_network.zone52.id
}

resource "google_compute_router_nat" "zone52-nat" {
  name                               = "my-zone52-nat"
  router                             = google_compute_router.zone52-router.name
  region                             = google_compute_router.zone52-router.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

