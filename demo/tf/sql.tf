resource "google_sql_database" "wordpress-database" {
  name     = "wordpress-database"
  instance = google_sql_database_instance.wordpress-db-mysql10.name
}

#resource "google_sql_user" "okhab" {
#  name     = "okhab"
#  instance = google_sql_database_instance.wordpress-db-mysql10.name
#
#}

resource "google_sql_database_instance" "wordpress-db-mysql10" {
  name             = "wordpress-db-mysql10"
  database_version = "MYSQL_5_6"
  region           = "us-east1"
  depends_on = [google_service_networking_connection.private-vpc-db-connection]
  deletion_protection = "false"
  settings {
    # Second-generation instance tiers are based on the machine
    # type. See argument reference below.
    tier = "db-f1-micro"
    ip_configuration {
      ipv4_enabled    = false
      private_network = google_compute_network.zone53.id
    }
    backup_configuration {
      binary_log_enabled = true
      enabled            = true
    }
  }
}

resource "google_sql_database_instance" "wordpress-db-mysql11" {
  name             = "wordpress-db-mysql11"
  database_version = "MYSQL_5_6"
  region           = "us-east1"
  depends_on       = [google_service_networking_connection.private-vpc-replica-connection]
  deletion_protection  = "false"
  master_instance_name = google_sql_database_instance.wordpress-db-mysql10.name 
  settings {
    # Second-generation instance tiers are based on the machine
    # type. See argument reference below.
    tier = "db-f1-micro"
    ip_configuration {
      ipv4_enabled    = false
      private_network = google_compute_network.zone53.id
    }
  }
  replica_configuration {
      failover_target = true
  }
}

resource "google_compute_global_address" "sql-private-ip" {
  name          = "sql-private-ip"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.zone53.id
}

resource "google_compute_global_address" "sql-replica-private-ip" {
  name          = "sql-replica-private-ip"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.zone53.id
}

resource "google_service_networking_connection" "private-vpc-db-connection" {
  network                 = google_compute_network.zone53.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.sql-private-ip.name]
}

resource "google_service_networking_connection" "private-vpc-replica-connection" {
  network                 = google_compute_network.zone53.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.sql-replica-private-ip.name]
}
