output "db_ip" {
  value = google_sql_database_instance.wordpress-db-mysql5.private_ip_address
}
