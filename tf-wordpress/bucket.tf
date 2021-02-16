resource "google_storage_bucket" "wp-bucket" {
  name          = "wp-bucket1"
  location      = "US"
  force_destroy = false
  uniform_bucket_level_access = true
}
