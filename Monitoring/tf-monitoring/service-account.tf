resource "google_service_account" "wp-service-account" {
  account_id   = "wp-service"
}

resource "google_service_account" "function-account" {
  account_id   = "function-account"
}

