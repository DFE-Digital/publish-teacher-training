terraform {

  required_version = "= 1.3.5"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.104.2"
    }
  }
  backend "azurerm" {
  }
}

provider "azurerm" {
  features {}

  skip_provider_registration = true
}
