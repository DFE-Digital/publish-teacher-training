locals {
  #infra_secrets = yamldecode(module.application_configuration.kubernetes_secret_name)
  environment  = "${var.app_environment}-${var.app_suffix}"
}
