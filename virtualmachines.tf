# Create Bastion public IP
resource "azurerm_public_ip" "ipBastion" {
  name                = "${local.prefixName}ip-Bastion"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  allocation_method   = "Static"
  domain_name_label   = "${local.prefixName}bastion"
}

#Create Bastion nic
resource "azurerm_network_interface" "nicBastion" {
  name                    = "${local.prefixName}nic-bastion"
  location                = data.azurerm_resource_group.rg.location
  resource_group_name     = data.azurerm_resource_group.rg.name
  internal_dns_name_label = "bastion"

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.Subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.ipBastion.id
  }
}

#Association of nic and nsg for Bastion VM
resource "azurerm_network_interface_security_group_association" "nicnsgbastion" {
  network_interface_id      = azurerm_network_interface.nicBastion.id
  network_security_group_id = azurerm_network_security_group.nsgBastion.id
}


# Create bastion virtual machine
resource "azurerm_linux_virtual_machine" "bastion" {
  name                  = "${local.prefixName}vm-bastion"
  location              = data.azurerm_resource_group.rg.location
  resource_group_name   = data.azurerm_resource_group.rg.name
  admin_username        = local.user
  size                  = "Standard_DS1_v2"
  network_interface_ids = [azurerm_network_interface.nicBastion.id]

  os_disk {
    name                 = "${local.prefixName}OsDisk-bastion"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
  admin_ssh_key {
    username   = local.user
    public_key = local.ssh_pub_key
  }
}



# Create App public IP
resource "azurerm_public_ip" "ipApp" {
  name                = "${local.prefixName}ip-App"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  domain_name_label   = "${local.prefixName}app"
}

#Create App nic
resource "azurerm_network_interface" "nicApp" {
  name                    = "${local.prefixName}nic-app"
  location                = data.azurerm_resource_group.rg.location
  resource_group_name     = data.azurerm_resource_group.rg.name
  internal_dns_name_label = "app"

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.Subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

#Association of nic and nsg for App VM
resource "azurerm_network_interface_security_group_association" "nicnsgapp" {
  network_interface_id      = azurerm_network_interface.nicApp.id
  network_security_group_id = azurerm_network_security_group.nsgApp.id
}


# Create app virtual machine
resource "azurerm_linux_virtual_machine" "app" {
  name                  = "${local.prefixName}vm-app"
  location              = data.azurerm_resource_group.rg.location
  resource_group_name   = data.azurerm_resource_group.rg.name
  admin_username        = local.user
  size                  = "Standard_DS1_v2"
  network_interface_ids = [azurerm_network_interface.nicApp.id]

  os_disk {
    name                 = "${local.prefixName}OsDisk-app"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
  admin_ssh_key {
    username   = local.user
    public_key = local.ssh_pub_key
  }
}

