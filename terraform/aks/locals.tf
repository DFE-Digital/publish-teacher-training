locals {
  environment            = "${var.app_environment}-${var.app_suffix}"
  review_additional_hostnames = var.app_environment == "review" ? ["find-review-${var.app_suffix}.${var.cluster}.teacherservices.cloud"] : ["find-review-${var.app_suffix}.${var.cluster}.development.teacherservices.cloud"]
  disable_database_environment_check = var.app_environment == "review" ? { DISABLE_DATABASE_ENVIRONMENT_CHECK = 1 } : {}
}
