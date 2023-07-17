data "azurerm_resource_group" "rg" {
  name = "b1e3-gr4"
}

resource "random_integer" "random" {
  min = 10
  max = 500
}

resource "random_password" "dbpass" {
  length      = 16
  min_lower   = 4
  min_upper   = 2
  special     = false
  min_numeric = 3
}

resource "random_password" "dbpassuser" {
  length      = 16
  min_lower   = 4
  min_upper   = 2
  special     = false
  min_numeric = 3
}

locals {
  ipSpace             = ["10.1.0.0/16"]
  prefixName          = "ill"
  path_to_private_key = "~/.ssh/terraform_key"
  ssh_pub_key         = file("~/.ssh/terraform_key.pub")
  user                = "nabila"
  dbserveradmin       = "mariadbadmin"
  dbuser              = "wikijsdbuser"
}

# Create virtual network
resource "azurerm_virtual_network" "Vnet" {
  name                = "${local.prefixName}-vn-virtual-network"
  address_space       = local.ipSpace
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
}

# Create subnet
resource "azurerm_subnet" "Subnet" {
  name                                      = "${local.prefixName}-subnet-VM"
  address_prefixes                          = ["10.1.1.0/24"]
  resource_group_name                       = data.azurerm_resource_group.rg.name
  virtual_network_name                      = azurerm_virtual_network.Vnet.name
  service_endpoints                         = ["Microsoft.Sql"]
  private_endpoint_network_policies_enabled = "true"
}

# Create Network Security Group and rule for Bastion
resource "azurerm_network_security_group" "nsgBastion" {
  name                = "${local.prefixName}-nsgBastion"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = data.external.adminipaddr.result.ip
    destination_address_prefix = "*"
  }
}

#Get adminuser public IP 
data "external" "adminipaddr" {
  program = ["bash", "-c", "curl -s 'https://ipinfo.io/json'"]
}

# Create Network Security Group and rule for App
resource "azurerm_network_security_group" "nsgApp" {
  name                = "${local.prefixName}-nsgApp"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name

  security_rule {
    name                       = "HTTP"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTPS"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

