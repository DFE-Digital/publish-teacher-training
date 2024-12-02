module "domains_infrastructure" {
  source                 = "./vendor/modules/domains//domains/infrastructure"
  hosted_zone            = var.hosted_zone
  tags                   = var.tags
  deploy_default_records = var.deploy_default_records
}
