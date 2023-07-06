resource "azurerm_storage_account" "staccount" {
  name                = "smb${random_string.random.result}"
  resource_group_name = data.azurerm_resource_group.rg.name

  location                 = data.azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  network_rules {
    default_action = "Allow"
    ip_rules       = [azurerm_public_ip.ipApp.ip_address]
  }
}

resource "azurerm_storage_share" "share" {
  name                 = "${local.prefixName}share-wikijs"
  storage_account_name = azurerm_storage_account.staccount.name
  quota                = 5
}


resource "azurerm_storage_share_directory" "sharedirectory" {
  name                 = "${local.prefixName}directory-wikijs"
  share_name           = azurerm_storage_share.share.name
  storage_account_name = azurerm_storage_account.staccount.name
}

