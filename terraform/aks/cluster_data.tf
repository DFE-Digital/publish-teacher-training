module "cluster_data" {
  source = "git::https://github.com/DFE-Digital/terraform-modules.git//aks/cluster_data?ref=stable"
  name   = var.cluster
}
