#Create a linux VM scale set of 8 instances
resource "azurerm_linux_virtual_machine_scale_set" "scaleset" {
  name                = "${local.prefixName}-scst"
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
    name    = azurerm_network_interface.nicApp.name
    primary = true
    ip_configuration {
      name                                         = "internal"
      subnet_id                                    = azurerm_subnet.Subnet.id
      application_gateway_backend_address_pool_ids = azurerm_application_gateway.gw.backend_address_pool[*].id
    }
  }
}

#Create an autoscaling rule
resource "azurerm_monitor_autoscale_setting" "autoscaleset" {
  name                = "${local.prefixName}-autoscst"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  target_resource_id  = azurerm_linux_virtual_machine_scale_set.scaleset.id

  profile {
    name = "defaultProfile"

    capacity {
      default = 6
      minimum = 2
      maximum = 8
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.scaleset.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = 90
      }

      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT1M"
      }
    }
    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.scaleset.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = 25
      }

      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT1M"
      }
    }
  }
  notification {
    email {
      custom_emails = ["nrizki@simplonformations.onmicrosoft.com", "moratasamantha@gmail.com"]
    }
  }
}