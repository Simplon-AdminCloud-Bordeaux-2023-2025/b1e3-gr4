#Create Mariadb server
resource "azurerm_mariadb_server" "dbserver" {
  name                         = "${local.prefixName}-mariadb-server"
  location                     = data.azurerm_resource_group.rg.location
  resource_group_name          = data.azurerm_resource_group.rg.name
  administrator_login          = local.dbserveradmin
  administrator_login_password = random_password.dbpass.result

  sku_name   = "GP_Gen5_2"
  storage_mb = 5120
  version    = "10.2"

  auto_grow_enabled                = true
  backup_retention_days            = 7
  geo_redundant_backup_enabled     = false
  public_network_access_enabled    = false
  ssl_enforcement_enabled          = false
  ssl_minimal_tls_version_enforced = "TLSEnforcementDisabled"
}

#Create application database
resource "azurerm_mariadb_database" "database" {
  name                = "wikijs"
  resource_group_name = data.azurerm_resource_group.rg.name
  server_name         = azurerm_mariadb_server.dbserver.name
  charset             = "utf8mb4"
  collation           = "utf8mb4_unicode_520_ci"
}

#Create db subnet
resource "azurerm_subnet" "dbsubnet" {
  name                                      = "${local.prefixName}-sn-mariadb"
  resource_group_name                       = data.azurerm_resource_group.rg.name
  virtual_network_name                      = azurerm_virtual_network.Vnet.name
  address_prefixes                          = [cidrsubnet(local.ipSpace[0], 8, 3)]
  service_endpoints                         = ["Microsoft.Sql"]
  private_endpoint_network_policies_enabled = "true"
}

#Create private dns zone
resource "azurerm_private_dns_zone" "dnszonedb" {
  name                = "privatelink.mariadb.database.azure.com"
  resource_group_name = data.azurerm_resource_group.rg.name
}

#Create a link between private dns zone and virtual network
resource "azurerm_private_dns_zone_virtual_network_link" "vnetlinkdb" {
  name                  = "${local.prefixName}-dnsvnetlink-db"
  resource_group_name   = data.azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.dnszonedb.name
  virtual_network_id    = azurerm_virtual_network.Vnet.id
}

#Create endpoint
resource "azurerm_private_endpoint" "pepdb" {
  name                = "${local.prefixName}-pep-db"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.Subnet.id
  private_service_connection {
    name                           = "mariadbprivatelink"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_mariadb_server.dbserver.id
    subresource_names              = ["mariadbServer"]
  }
  private_dns_zone_group {
    name                 = "dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.dnszonedb.id]
  }
}

#Get endpoint connection informations
data "azurerm_private_endpoint_connection" "private-ip-db" {
  name                = azurerm_private_endpoint.pepdb.name
  resource_group_name = data.azurerm_resource_group.rg.name
  depends_on          = [azurerm_mariadb_server.dbserver]
}

#Create private dns record in the private dns zone
resource "azurerm_private_dns_a_record" "dnsrecorddb" {
  name                = "${local.prefixName}-privdnsrecdb"
  zone_name           = azurerm_private_dns_zone.dnszonedb.name
  resource_group_name = data.azurerm_resource_group.rg.name
  ttl                 = 300
  records             = [data.azurerm_private_endpoint_connection.private-ip-db.private_service_connection[0].private_ip_address]
}
