output "frontend-ip" {
  value = google_compute_global_address.wordpress-front.address
}
