resource "azurerm_recovery_services_vault" "vault" {
  name                = "tfex-recovery-vault"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  sku                 = "Standard"
}


resource "azurerm_backup_container_storage_account" "protection-container" {
  resource_group_name = data.azurerm_resource_group.rg.name
  recovery_vault_name = azurerm_recovery_services_vault.vault.name
  storage_account_id  = azurerm_storage_account.staccount.id
}

resource "azurerm_backup_policy_file_share" "backup-policy" {
  name                = "tfex-recovery-vault-policy"
  resource_group_name = data.azurerm_resource_group.rg.name
  recovery_vault_name = azurerm_recovery_services_vault.vault.name

  backup {
    frequency = "Daily"
    time      = "09:30"
  }

  retention_daily {
    count = 10
  }
}

resource "azurerm_backup_protected_file_share" "share1" {
  resource_group_name       = data.azurerm_resource_group.rg.name
  recovery_vault_name       = azurerm_recovery_services_vault.vault.name
  source_storage_account_id = azurerm_backup_container_storage_account.protection-container.storage_account_id
  source_file_share_name    = azurerm_storage_share.share.name
  backup_policy_id          = azurerm_backup_policy_file_share.backup-policy.id

  lifecycle {
    ignore_changes = [source_storage_account_id]
  }
}





