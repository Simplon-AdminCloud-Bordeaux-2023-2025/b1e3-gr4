locals {
  backend_address_pool_name      = "${azurerm_virtual_network.Vnet.name}-beap"
  frontend_port_name             = "${azurerm_virtual_network.Vnet.name}-feport"
  frontend_ip_configuration_name = "${azurerm_virtual_network.Vnet.name}-feip"
  http_setting_name              = "${azurerm_virtual_network.Vnet.name}-be-htst"
  listener_name                  = "${azurerm_virtual_network.Vnet.name}-httplstn"
  request_routing_rule_name      = "${azurerm_virtual_network.Vnet.name}-rqrt"
  redirect_configuration_name    = "${azurerm_virtual_network.Vnet.name}-rdrcfg"
}

resource "azurerm_subnet" "gatewayfront" {
  name                 = "${local.prefixName}sn-gw"
  resource_group_name  = data.azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.Vnet.name
  address_prefixes     = ["10.1.2.0/24"]
}

resource "azurerm_application_gateway" "gw" {
  name                = "${local.prefixName}gw"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "my-gateway-ip-configuration"
    subnet_id = azurerm_subnet.gatewayfront.id
  }

  frontend_port {
    name = local.frontend_port_name
    port = 80
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.ipApp.id
  }

  backend_address_pool {
    name  = local.backend_address_pool_name
  }

  backend_http_settings {
    name                  = local.http_setting_name
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 360
  }

  http_listener {
    name                           = local.listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = local.request_routing_rule_name
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
    priority                   = 1
  }
}

resource "azurerm_network_interface_application_gateway_backend_address_pool_association" "gwasso" {
  network_interface_id    = azurerm_network_interface.nicApp.id
  ip_configuration_name   = "internal"
  backend_address_pool_id = tolist(azurerm_application_gateway.gw.backend_address_pool).0.id
}