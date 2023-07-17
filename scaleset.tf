resource "azurerm_linux_virtual_machine_scale_set" "scaleset" {
  name                = "${local.prefixName}vm-app"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  sku                 = "Standard_F2"
  instances           = 8
  admin_username      = local.user

  admin_ssh_key {
    username   = local.user
    public_key = local.ssh_pub_key
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  network_interface {
    name = "scst"
    primary = true
    ip_configuration {
      name                                         = "internal"
      subnet_id = azurerm_subnet.Subnet.id
      application_gateway_backend_address_pool_ids = azurerm_application_gateway.gw.backend_address_pool[*].id
    }
  }
}