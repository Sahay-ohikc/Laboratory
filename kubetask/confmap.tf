resource "kubernetes_config_map" "production" {
  metadata {
    name      = "config-production"
  }

  data = {
    NODE_ENV = "production"
    APP_NAME = "guestbook"
  }
}
