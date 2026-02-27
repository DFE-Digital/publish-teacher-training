terraform {
  required_version = "=1.14.5"

  backend "azurerm" {}

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.61.0"
    }
    statuscake = {
      source  = "StatusCakeDev/statuscake"
      version = "2.2.2"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.32.0"
    }
  }
}

provider "azurerm" {
  resource_provider_registrations = "none"

  features {}
}

provider "kubernetes" {
  host                   = module.cluster_data.kubernetes_host
  cluster_ca_certificate = module.cluster_data.kubernetes_cluster_ca_certificate

exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "kubelogin"
    args        = module.cluster_data.kubelogin_args
  }
}

provider "statuscake" {
  api_token = data.azurerm_key_vault_secret.statuscake_api_token.value
}
