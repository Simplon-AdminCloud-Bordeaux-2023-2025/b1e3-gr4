locals {
  backend_address_pool_name       = "${local.prefixName}-beap"
  frontend_port_name_http         = "${local.prefixName}-feport-http"
  frontend_port_name_https        = "${local.prefixName}-feport-https"
  frontend_ip_configuration_name  = "${local.prefixName}-feip"
  http_setting_name               = "${local.prefixName}-be-http-st"
  http_listener_name              = "${local.prefixName}-http-lstn"
  https_listener_name             = "${local.prefixName}-https-lstn"
  http_request_routing_rule_name  = "${local.prefixName}-http-rqrt"
  https_request_routing_rule_name = "${local.prefixName}-https-rqrt"
  redirect_configuration_name     = "${local.prefixName}-rdrcfg"
}

#Create app gateway subnet
resource "azurerm_subnet" "gatewayfront" {
  name                 = "${local.prefixName}-sn-gw"
  resource_group_name  = data.azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.Vnet.name
  address_prefixes     = ["10.1.2.0/24"]
}

#Create app gateway 
resource "azurerm_application_gateway" "gw" {
  name                = "${local.prefixName}-gw"
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
    name = local.frontend_port_name_http
    port = 80
  }

  frontend_port {
    name = local.frontend_port_name_https
    port = 443
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.ipApp.id
  }

  backend_address_pool {
    name         = local.backend_address_pool_name
    ip_addresses = [azurerm_network_interface.nicApp.private_ip_address]
    fqdns        = ["${azurerm_storage_account.staccount2.name}.blob.core.windows.net"]
  }

  backend_http_settings {
    name                                = local.http_setting_name
    cookie_based_affinity               = "Disabled"
    port                                = 80
    protocol                            = "Http"
    request_timeout                     = 360
    pick_host_name_from_backend_address = "true"
  }

  http_listener {
    name                           = local.http_listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name_http
    protocol                       = "Http"
    host_name                      = azurerm_public_ip.ipApp.fqdn
  }

  request_routing_rule {
    name               = local.http_request_routing_rule_name
    rule_type          = "PathBasedRouting"
    http_listener_name = local.http_listener_name
    priority           = 100
    url_path_map_name  = "pathmap"
  }

  url_path_map {
    name                               = "pathmap"
    default_backend_address_pool_name  = local.backend_address_pool_name
    default_backend_http_settings_name = local.http_setting_name

    path_rule {
      name                        = "pathmap"
      redirect_configuration_name = "pathmap"
      paths                       = ["/.well-known/acme-challenge/*"]
    }
  }

  redirect_configuration {
    name                 = "pathmap"
    redirect_type        = "Permanent"
    target_url           = "https://${azurerm_storage_account.staccount2.name}.blob.core.windows.net/${azurerm_storage_container.container.name}"
    include_path         = true
    include_query_string = false
  }

  #ssl_certificate {
   # name     = "certificat"
    #data     = filebase64("./ansibleplaybooks/challengeHTTP/roles/cert.pfx")
    #password = "challengepassword"
  #}


  #http_listener {
   # name                           = local.https_listener_name
    #ssl_certificate_name           = "certificat"
    #frontend_ip_configuration_name = local.frontend_ip_configuration_name
    #frontend_port_name             = local.frontend_port_name_https
    #protocol                       = "Https"
    #host_name                      = azurerm_public_ip.ipApp.fqdn
  #}

  #request_routing_rule {
   # name                       = local.https_request_routing_rule_name
    #rule_type                  = "Basic"
    #http_listener_name         = local.https_listener_name
    #priority                   = 50
    #backend_http_settings_name = local.http_setting_name
    #backend_address_pool_name  = local.backend_address_pool_name
  #}
}
