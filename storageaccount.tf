#Create first storage account-used to add a file share to the app VM
resource "azurerm_storage_account" "staccount" {
  name                     = "nabsmb${random_integer.random.result}"
  resource_group_name      = data.azurerm_resource_group.rg.name
  location                 = data.azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  network_rules {
    default_action = "Allow"
    ip_rules       = [azurerm_public_ip.ipApp.ip_address]
  }
}

#Create file share storage
resource "azurerm_storage_share" "share" {
  name                 = "${local.prefixName}share-wikijs"
  storage_account_name = azurerm_storage_account.staccount.name
  quota                = 5
}

#Create file share directory
resource "azurerm_storage_share_directory" "sharedirectory" {
  name                 = "${local.prefixName}directory-wikijs"
  share_name           = azurerm_storage_share.share.name
  storage_account_name = azurerm_storage_account.staccount.name
}

#Create second storage account-used for certificate with let's encrypt
resource "azurerm_storage_account" "staccount2" {
  name                          = "nabsmb${random_integer.random.result}2"
  resource_group_name           = data.azurerm_resource_group.rg.name
  location                      = data.azurerm_resource_group.rg.location
  account_tier                  = "Standard"
  account_replication_type      = "LRS"
  public_network_access_enabled = "true"

  network_rules {
    default_action = "Allow"
    ip_rules       = [azurerm_public_ip.ipApp.ip_address]
  }
}

#Create container
resource "azurerm_storage_container" "container" {
  name                  = "${local.prefixName}ct"
  storage_account_name  = azurerm_storage_account.staccount2.name
  container_access_type = "blob"
}

resource "azurerm_storage_blob" "blob" {
  name                   = ".well-known/acme-challenge/random.jpg"
  storage_account_name   = azurerm_storage_account.staccount2.name
  storage_container_name = azurerm_storage_container.container.name
  content_type           = "image/jpg"
  type                   = "Block"
  source                 = "./letsencrypt/random.jpg"
}