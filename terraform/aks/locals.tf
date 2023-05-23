locals {
  #infra_secrets = yamldecode(module.application_configuration.kubernetes_secret_name)
  environment            = "${var.app_environment}-${var.app_suffix}"
  review_additional_hostnames = var.app_environment == "review" ? ["find-review-${var.app_suffix}.${var.cluster}.teacherservices.cloud"] : ["find-review-${var.app_suffix}.${var.cluster}.development.teacherservices.cloud"]
  # app_name_suffix  = var.app_name == null ? var.paas_app_environment : var.app_name
}
