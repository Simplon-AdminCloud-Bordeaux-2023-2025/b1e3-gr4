# Création du workspace Azure Monitor
resource "azurerm_log_analytics_workspace" "workspace" {
  name                = "${local.prefixName}-monitoring-workspace"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

# Associer l'espace de travail au compte de stockage
resource "azurerm_log_analytics_linked_storage_account" "workspace_linked_storage" {
  data_source_type      = "CustomLogs"
  resource_group_name   = data.azurerm_resource_group.rg.name
  workspace_resource_id = azurerm_log_analytics_workspace.workspace.id
  storage_account_ids   = [azurerm_storage_account.staccount.id]
}


# Création d'un classeur regroupant des métriques de la machine applicative, de la base de donnée et du compte de stockage
resource "azurerm_application_insights_workbook" "workbook" {
  name                = "06f54e0a-1bfa-11ee-be56-0242ac120002"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  display_name        = "workbook1"
  source_id           = data.azurerm_client_config.current.subscription_id
  data_json = jsonencode({
    "version" : "Notebook/1.0",
    "items" : [
      {
        "type" : 1,
        "content" : {
          "json" : "Metriques de la base de données, de la machine applicative et du compte de stockage."
        },
        "name" : "text - 0"
      },
      {
        "type" : 10,
        "content" : {
          "chartId" : "workbook76a04e93-6e87-4de3-a31b-8e6f79d6ecb5",
          "version" : "MetricsItem/2.0",
          "size" : 0,
          "chartType" : 2,
          "resourceType" : "microsoft.compute/virtualmachines",
          "metricScope" : 0,
          "resourceIds" : [
           "/subscriptions/c56aea2c-50de-4adc-9673-6a8008892c21/resourceGroups/b1e3-gr4/providers/Microsoft.Compute/virtualMachines/sam-vm-app"
          ],
          "timeContext" : {
            "durationMs" : 3600000
          },
          "metrics" : [
            {
              "namespace" : "microsoft.compute/virtualmachines",
              "metric" : "microsoft.compute/virtualmachines--Percentage CPU",
              "aggregation" : 4,
              "splitBy" : null,
              "columnName" : "CPU"
            },
            {
              "namespace" : "microsoft.compute/virtualmachines",
              "metric" : "microsoft.compute/virtualmachines--VmAvailabilityMetric",
              "aggregation" : 4,
              "columnName" : "Availability"
            }
          ],
          "gridSettings" : {
            "rowLimit" : 10000
          }
        },
        "name" : "métrique - 1"
      },
      {
        "type" : 10,
        "content" : {
          "chartId" : "workbook3f34abd3-339e-4233-9f28-121dd2631da7",
          "version" : "MetricsItem/2.0",
          "size" : 0,
          "chartType" : 2,
          "resourceType" : "microsoft.DBforMariaDB/servers"
          "metricScope" : 0,
          "resourceIds" : [
           "/subscriptions/c56aea2c-50de-4adc-9673-6a8008892c21/resourceGroups/b1e3-gr4/providers/Microsoft.DBforMariaDB/servers/sam-mariadb-server"
          ],
          "timeContext" : {
            "durationMs" : 1800000
          },
          "metrics" : [
            {
              "namespace" : "microsoft.DBforMariaDB/servers",
              "metric" : "microsoft.DBforMariaDB/servers-Saturation-backup_storage_used",
              "aggregation" : 4,
              "splitBy" : null,
              "columnName" : "Backup storage "
            }
          ],
          "gridSettings" : {
            "rowLimit" : 10000
          }
        },
        "name" : "métrique - 2"
      },
    ],
    "fallbackResourceIds" : [
      data.azurerm_client_config.current.subscription_id
    ],
    "$schema" : "https://github.com/Microsoft/Application-Insights-Workbooks/blob/master/schema/workbook.json"
  })

}

# Activation de la surveillance de la machine virtuelle dans Azure Monitor
resource "azurerm_monitor_diagnostic_setting" "vm_monitoring" {
  name                       = "${local.prefixName}-vm-monitoring"
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
  name                       = "${local.prefixName}-db-monitoring"
  target_resource_id         = azurerm_mariadb_server.dbserver.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.workspace.id

  metric {
    category = "AllMetrics"

    retention_policy {
      enabled = false
    }
  }
}



# Création d'une alerte en cas d'indisponibilité de l'application
resource "azurerm_monitor_scheduled_query_rules_alert" "app_unavailability_alert" {
  name                = "${local.prefixName}-app-unavailability-alert"
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
  name                = "${local.prefixName}-cpu-usage-alert"
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
  name                = "${local.prefixName}-storage-space-alert"
  resource_group_name = data.azurerm_resource_group.rg.name
  description         = "Alert when storage space is less than 10%"
  frequency           = "PT1H"
  window_size         = "PT6H"
  scopes              = [azurerm_storage_account.staccount.id]

  criteria {
     metric_namespace = "Microsoft.Storage/storageAccounts"
    metric_name      = "UsedCapacity"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 4.5 * 1024 * 1024 * 1024 # 4,5 Go
  }

  action {
    action_group_id = azurerm_monitor_action_group.notification_group.id
  }
}


# Création du groupe d'action de notification
resource "azurerm_monitor_action_group" "notification_group" {
  name                = "${local.prefixName}-notification-group"
  resource_group_name = data.azurerm_resource_group.rg.name
  short_name          = "NotifGroup"

  email_receiver {
    name          = "email-julie"
    email_address = "jpaillusseau.ext@simplon.co"
  }
  email_receiver {
    name          = "email-samantha"
    email_address = "moratasamantha@gmail.com"
  }
}



