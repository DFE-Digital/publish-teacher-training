locals {
  uploads_default_storage_account_name = "${var.azure_resource_prefix}${var.service_short}dbbkpsan${var.config_short}sa"
}


resource "azurerm_storage_account" "sanitised_uploads" {
  count                             = var.enable_sanitised_storage ? 1 : 0

  name                              = local.uploads_default_storage_account_name
  resource_group_name               = "${var.azure_resource_prefix}-${var.service_short}-${var.config_short}-rg"
  location                          = "UK South"
  account_replication_type          = "LRS"
  account_tier                      = "Standard"
  account_kind                      = "StorageV2"
  min_tls_version                   = "TLS1_2"
  infrastructure_encryption_enabled = true
  allow_nested_items_to_be_public   = false
  cross_tenant_replication_enabled  = false

  blob_properties {

    container_delete_retention_policy {
      days = 7
    }
  }

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_storage_management_policy" "backup" {
  count = var.enable_sanitised_storage ? 1 : 0

  storage_account_id = azurerm_storage_account.sanitised_uploads[0].id

  rule {
    name    = "DeleteAfter7Days"
    enabled = true
    filters {
      blob_types = ["blockBlob"]
    }
    actions {
      base_blob {
        delete_after_days_since_modification_greater_than = 7
      }
    }
  }
}


resource "azurerm_storage_container" "sanitised_uploads" {
  count                 = var.enable_sanitised_storage ? 1 : 0

  name                  = "database-backup"
  storage_account_name  = azurerm_storage_account.sanitised_uploads[0].name
  container_access_type = "private"
}