output "ruter" {
  value = google_compute_router.zone52-router
}

output "workhorseip" {
  value = google_compute_instance.bastion52.network_interface.0.access_config.0.nat_ip
}