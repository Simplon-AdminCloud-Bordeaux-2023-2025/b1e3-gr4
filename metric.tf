# Création du workspace Azure Monitor
resource "azurerm_log_analytics_workspace" "workspace" {
  name                = "${local.prefixName}monitoring-workspace"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}


resource "azurerm_application_insights_workbook" "workbook" {
  name                = "85b3e8bb-fc93-40be-83f2-98f6bec18ba0"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  display_name        = "workbook1"

  data_json = jsonencode({
    appUnavailabilityAlert = {
      value = "${local.prefixName}app-unavailability-alert"
    },
    cpuUsageAlert = {
      value = "${local.prefixName}cpu-usage-alert"
    },
    storageSpaceAlert = {
      value = "${local.prefixName}storage-space-alert"
    },
    "isLocked" = false,
    "fallbackResourceIds" = [
      "Azure Monitor"
    ],
    "metrics" = [
      {
        "name": "appUnavailabilityAlert",
        "aggregationType": "Count",
        "timeRange": "P1D",
       
      },
      {
        "name": "cpuUsageAlert",
        "aggregationType": "Avg",
        "timeRange": "P7D",
       
      },
     
    ]
  })

  tags = {
    ENV = "Test"
  }
}



# Activation de la surveillance de la machine virtuelle dans Azure Monitor
resource "azurerm_monitor_diagnostic_setting" "vm_monitoring" {
  name                       = "${local.prefixName}vm-monitoring"
  target_resource_id         = azurerm_linux_virtual_machine.app.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.workspace.id
  
  
  metric {
    category = "AllMetrics"
    

    retention_policy {
      enabled = false
    }
  }
}

# Activation de la surveillance de la base de données MariaDB dans Azure Monitor
resource "azurerm_monitor_diagnostic_setting" "db_monitoring" {
  name                       = "${local.prefixName}db-monitoring"
  target_resource_id         = azurerm_mariadb_server.dbserver.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.workspace.id
 
    metric {
    category = "AllMetrics"

    retention_policy {
      enabled = false
    }
  }
}

# Activation de la surveillance de l'espace de stockage dans Azure Monitor
# resource "azurerm_monitor_diagnostic_setting" "storage_monitoring" {
#   name                       = "${local.prefixName}storage-monitoring"
#   target_resource_id         = azurerm_storage_account.staccount.id
#   log_analytics_workspace_id = azurerm_log_analytics_workspace.workspace.id
#   metric {
#     category = "AllMetrics"
#     enabled  = true

#     retention_policy {
#       enabled = true
#       days    = 365
#     }
#   }
# }


# Création d'une alerte en cas d'indisponibilité de l'application
resource "azurerm_monitor_scheduled_query_rules_alert" "app_unavailability_alert" {
  name                = "${local.prefixName}app-unavailability-alert"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  description         = "Alert when application is unavailable"
  severity            = 2

  data_source_id = azurerm_linux_virtual_machine.app.id
  time_window    = 30
  query          = <<QUERY
Heartbeat | summarize LastHeartbeat = max(TimeGenerated) by Computer | 
where Computer == "${azurerm_linux_virtual_machine.app.name}" | 
where LastHeartbeat < ago(5m)
QUERY
  frequency      = 5

  trigger {
    operator  = "GreaterThan"
    threshold = 0
  }

  action {
    action_group = [azurerm_monitor_action_group.notification_group.id]
  }
}

# Création d'une alerte si l'utilisation du CPU dépasse 90% sur la machine virtuelle d'application
resource "azurerm_monitor_metric_alert" "cpu_usage_alert" {
  name                = "${local.prefixName}cpu-usage-alert"
  resource_group_name = data.azurerm_resource_group.rg.name
  description         = "Alert when CPU usage exceeds 90%"
  severity            = 2
  scopes              = [azurerm_linux_virtual_machine.app.id]
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Percentage CPU"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 90
  }

  action {
    action_group_id = azurerm_monitor_action_group.notification_group.id
  }
}

# Création d'une alerte si l'espace disponible sur l'espace de stockage est inférieur à 10%
resource "azurerm_monitor_metric_alert" "storage_space_alert" {
  name                = "${local.prefixName}storage-space-alert"
  resource_group_name = data.azurerm_resource_group.rg.name
  description         = "Alert when storage space is less than 10%"
  severity            = 2
  window_size         = "PT1H"
  scopes              = [azurerm_storage_account.staccount.id]

  criteria {
    metric_namespace = "Microsoft.Storage/storageAccounts"
    metric_name      = "UsedCapacity"
    aggregation      = "Average"
    operator         = "LessThan"
    threshold        = 10
  }

  action {
    action_group_id = azurerm_monitor_action_group.notification_group.id
  }
}


# Création du groupe d'action de notification
resource "azurerm_monitor_action_group" "notification_group" {
  name                = "${local.prefixName}notification-group"
  resource_group_name = data.azurerm_resource_group.rg.name
  short_name          = "NotifGroup"

  email_receiver {
    name          = "email-julie"
    email_address = "email@example.com"
  }
  email_receiver {
    name          = "email-dom"
    email_address = "dtauzin.ext@simplon.co"
  }
}



