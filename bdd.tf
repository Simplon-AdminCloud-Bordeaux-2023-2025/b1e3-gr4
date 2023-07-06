resource "random_password" "dbpass" {
  length           = 16
  special          = true
  min_lower        = 4
  min_upper        = 2
  min_special      = 2
  min_numeric      = 3
  override_special = "!;:?"
}

resource "azurerm_mariadb_server" "dbserver" {
  name                = "${local.prefixName}mariadb-server"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name

  administrator_login          = "mariadbadmin"
  administrator_login_password = "otarierouge0607!"

  sku_name   = "GP_Gen5_2"
  storage_mb = 5120
  version    = "10.2"

  auto_grow_enabled                = true
  backup_retention_days            = 7
  geo_redundant_backup_enabled     = false
  public_network_access_enabled    = true
  ssl_enforcement_enabled          = false
  ssl_minimal_tls_version_enforced = "TLS1_2"
}


resource "azurerm_subnet" "dbsubnet" {
  name                 = "${local.prefixName}subnet-mariadb"
  resource_group_name  = data.azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.Vnet.name
  address_prefixes     = ["10.1.3.0/24"]
  service_endpoints    = ["Microsoft.Sql"]
}

resource "azurerm_mariadb_firewall_rule" "apprule" {
  name                = "${local.prefixName}firewalldbrule"
  resource_group_name = data.azurerm_resource_group.rg.name
  server_name         = azurerm_mariadb_server.dbserver.name
  start_ip_address    = azurerm_public_ip.ipApp.ip_address
  end_ip_address      = azurerm_public_ip.ipApp.ip_address
}

resource "azurerm_mariadb_virtual_network_rule" "subnetasso" {
  name                = "${local.prefixName}mariadb-vnet-rule"
  resource_group_name = data.azurerm_resource_group.rg.name
  server_name         = azurerm_mariadb_server.dbserver.name
  subnet_id           = azurerm_subnet.dbsubnet.id
}

resource "azurerm_mariadb_database" "database" {
  name                = "wikijs"
  resource_group_name = data.azurerm_resource_group.rg.name
  server_name         = azurerm_mariadb_server.dbserver.name
  charset             = "utf8mb4"
  collation           = "utf8mb4_unicode_520_ci"
}