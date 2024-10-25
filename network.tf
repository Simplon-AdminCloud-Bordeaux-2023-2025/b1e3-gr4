#Get resource group information
data "azurerm_resource_group" "rg" {
  name = "b1e3-gr4"
}

#Generate random number - used to make sure storage account and key vault have unique names
resource "random_integer" "random" {
  min = 10
  max = 500
}

#Generate password for database server administrator
resource "random_password" "dbpass" {
  length      = 16
  min_lower   = 4
  min_upper   = 2
  special     = false
  min_numeric = 3
}

#Generate password for database user
resource "random_password" "dbpassuser" {
  length      = 16
  min_lower   = 4
  min_upper   = 2
  special     = false
  min_numeric = 3
}

#Generic variables
locals {
  ipSpace = ["10.1.0.0/16"]
  # prefixName          = "sn${data.azurerm_resource_group.rg.name}"
  prefixName          = "name3"
  path_to_private_key = "~/.ssh/terraform_key"
  ssh_pub_key         = file("~/.ssh/terraform_key.pub")
  user                = "nabila"
  dbserveradmin       = "mariadbadmin"
  dbuser              = "wikijsdbuser"
  admin_users = {
    nabila   = "nrizki@simplonformations.onmicrosoft.com"
    samantha = "smorata@simplonformations.onmicrosoft.com"
  }
}

# Create virtual network
resource "azurerm_virtual_network" "Vnet" {
  name                = "${local.prefixName}-vn"
  address_space       = local.ipSpace
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
}

# Create VM subnet
resource "azurerm_subnet" "Subnet" {
  name                                      = "${local.prefixName}-sn-VM"
  address_prefixes                          = [cidrsubnet(local.ipSpace[0], 8, 1)]
  resource_group_name                       = data.azurerm_resource_group.rg.name
  virtual_network_name                      = azurerm_virtual_network.Vnet.name
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

