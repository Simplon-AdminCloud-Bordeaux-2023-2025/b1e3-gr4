#Create first storage account-used to add a file share to the app VM
resource "azurerm_storage_account" "staccount" {
  name                     = replace("${local.prefixName}stsmb${random_integer.random.result}", "-", "")
  resource_group_name      = data.azurerm_resource_group.rg.name
  location                 = data.azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

#Create file share storage
resource "azurerm_storage_share" "share" {
  name                 = "${local.prefixName}-share-wikijs"
  storage_account_name = azurerm_storage_account.staccount.name
  quota                = 5
}

#Create file share directory
resource "azurerm_storage_share_directory" "sharedirectory" {
  name                 = "${local.prefixName}-directory-wikijs"
  share_name           = azurerm_storage_share.share.name
  storage_account_name = azurerm_storage_account.staccount.name
}

#Create private dns zone
resource "azurerm_private_dns_zone" "dnszonefileshare" {
  name                = "privatelink.file.core.windows.net"
  resource_group_name = data.azurerm_resource_group.rg.name
}

#Create a link between private dns zone and virtual network
resource "azurerm_private_dns_zone_virtual_network_link" "vnetlinkfileshare" {
  name                  = "${local.prefixName}-dnsvnetlink-fileshare"
  resource_group_name   = data.azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.dnszonefileshare.name
  virtual_network_id    = azurerm_virtual_network.Vnet.id
}

#Create endpoint
resource "azurerm_private_endpoint" "pepfileshare" {
  name                = "${local.prefixName}-pep-fileshare"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.Subnet.id
  private_service_connection {
    name                           = "fileshareprivatelink"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_storage_account.staccount.id
    subresource_names              = ["file"]
  }
  private_dns_zone_group {
    name                 = "dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.dnszonefileshare.id]
  }
}

#Get endpoint connection informations
data "azurerm_private_endpoint_connection" "private-ip-fileshare" {
  name                = azurerm_private_endpoint.pepfileshare.name
  resource_group_name = data.azurerm_resource_group.rg.name
  depends_on          = [azurerm_storage_account.staccount]
}

#Create private dns record in the private dns zone
resource "azurerm_private_dns_a_record" "dnsrecordfileshare" {
  name                = "${local.prefixName}-privdnsrec-fileshare"
  zone_name           = azurerm_private_dns_zone.dnszonefileshare.name
  resource_group_name = data.azurerm_resource_group.rg.name
  ttl                 = 300
  records             = [data.azurerm_private_endpoint_connection.private-ip-fileshare.private_service_connection[0].private_ip_address]
}

#Create second storage account-used for certificate with let's encrypt
resource "azurerm_storage_account" "staccount2" {
  name                          = replace("${local.prefixName}stct${random_integer.random.result}", "-", "")
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
  name                  = "${local.prefixName}-ct"
  storage_account_name  = azurerm_storage_account.staccount2.name
  container_access_type = "blob"
}

#Create blob with a random image
resource "azurerm_storage_blob" "blob" {
  name                   = ".well-known/acme-challenge/random.jpg"
  storage_account_name   = azurerm_storage_account.staccount2.name
  storage_container_name = azurerm_storage_container.container.name
  content_type           = "image/jpg"
  type                   = "Block"
  source                 = "./random.jpg"
}