terraform {
  required_version = "~> 1.4"

  backend "azurerm" {}

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.52"
    }
  }
}
