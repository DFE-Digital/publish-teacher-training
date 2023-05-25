module "domains_infrastructure" {
  source                 = "git::https://github.com/DFE-Digital/terraform-modules.git//domains/infrastructure?ref=stable"
  hosted_zone            = var.hosted_zone
  tags                   = var.tags
  deploy_default_records = var.deploy_default_records
}
