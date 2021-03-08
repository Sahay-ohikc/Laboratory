resource "google_sql_database" "wordpress-database" {
  name     = "wordpress-database"
  instance = google_sql_database_instance.wordpress-db-mysql7.name
}

resource "google_sql_database_instance" "wordpress-db-mysql7" {
  name             = "wordpress-db-mysql7"
  database_version = "MYSQL_5_6"
  region           = "us-east1"
  depends_on = [google_service_networking_connection.private_vpc_connection]
  deletion_protection = "false"
  settings {
    # Second-generation instance tiers are based on the machine
    # type. See argument reference below.
    tier = "db-f1-micro"
    ip_configuration {
      ipv4_enabled    = false
      private_network = google_compute_network.zone53.id
    }
  }
}

resource "google_compute_global_address" "sql-private-ip" {
  name          = "sql-private-ip"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.zone53.id
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.zone53.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.sql-private-ip.name]
}
