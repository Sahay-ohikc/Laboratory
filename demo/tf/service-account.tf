resource "google_service_account" "wp-service-account" {
  account_id   = "wp-service"
}

resource "google_storage_bucket_iam_member" "bucket-server-link" {
  bucket = google_storage_bucket.wp-bucket.name
  role = "roles/storage.admin"
  member = "serviceAccount:${google_service_account.wp-service-account.email}"
}
