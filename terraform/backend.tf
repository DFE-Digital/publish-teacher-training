terraform {
  backend "azurerm" {
    container_name       = "tfstatestr"
  }
}
