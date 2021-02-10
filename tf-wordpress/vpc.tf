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
