resource "google_dns_managed_zone" "sahay-pp" {
  name     = "sahay-pp"
  dns_name = "sahay.pp.ua."
}

resource "google_dns_record_set" "sahay-pp" {  
  managed_zone = google_dns_managed_zone.sahay-pp.name
  name         = "www.sahay.pp.ua."
  type         = "A"
#  rrdatas      = [data.kubernetes_ingress.ingresstroller.status.load_balancer.ip]
  rrdatas      = [google_compute_global_address.kube-front.address]
  ttl          = 300
} 

resource "google_compute_global_address" "kube-front" {
  name = "kube-front"
}


