provider "google" {
  project = "okhab-education-25433"
  region  = "us-east1"
}

data "google_client_config" "default" {}

provider "kubernetes" {
  host                   = module.gke.endpoint
  cluster_ca_certificate = base64decode(module.gke.ca_certificate)
  token                  = data.google_client_config.default.access_token
  load_config_file       = false
}
