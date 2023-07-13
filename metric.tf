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

# Création d'un classeur regroupant des métriques de la machine applicative, de la base de donnée et du compte de stockage
# resource "azurerm_application_insights_workbook" "workbook" {
#   name                = "06f54e0a-1bfa-11ee-be56-0242ac120002"
#   resource_group_name = data.azurerm_resource_group.existing.name
#   location            = data.azurerm_resource_group.existing.location
#   display_name        = "${local.group_name}-workbook"
#   source_id           = "c56aea2c-50de-4adc-9673-6a8008892c21"
#   data_json = jsonencode({
#     "version" : "Notebook/1.0",
#     "items" : [
#       {
#         "type" : 1,
#         "content" : {
#           "json" : "Metriques de la base de données, de la machine applicative et du compte de stockage."
#         },
#         "name" : "text - 0"
#       },
#       {
#         "type" : 10,
#         "content" : {
#           "chartId" : "workbook76a04e93-6e87-4de3-a31b-8e6f79d6ecb5",
#           "version" : "MetricsItem/2.0",
#           "size" : 0,
#           "chartType" : 2,
#           "resourceType" : "microsoft.compute/virtualmachines",
#           "metricScope" : 0,
#           "resourceIds" : [
#             "/subscriptions/c56aea2c-50de-4adc-9673-6a8008892c21/resourceGroups/b1e3-gr1/providers/Microsoft.Compute/virtualMachines/b1e3-gr1-vm-gitea"
#           ],
#           "timeContext" : {
#             "durationMs" : 3600000
#           },
#           "metrics" : [
#             {
#               "namespace" : "microsoft.compute/virtualmachines",
#               "metric" : "microsoft.compute/virtualmachines--Percentage CPU",
#               "aggregation" : 4,
#               "splitBy" : null,
#               "columnName" : "CPU"
#             },
#             {
#               "namespace" : "microsoft.compute/virtualmachines",
#               "metric" : "microsoft.compute/virtualmachines--VmAvailabilityMetric",
#               "aggregation" : 4,
#               "columnName" : "Availability"
#             }
#           ],
#           "gridSettings" : {
#             "rowLimit" : 10000
#           }
#         },
#         "name" : "métrique - 1"
#       },
#       {
#         "type" : 10,
#         "content" : {
#           "chartId" : "workbook3f34abd3-339e-4233-9f28-121dd2631da7",
#           "version" : "MetricsItem/2.0",
#           "size" : 0,
#           "chartType" : 2,
#           "resourceType" : "microsoft.dbforpostgresql/servers",
#           "metricScope" : 0,
#           "resourceIds" : [
#             "/subscriptions/c56aea2c-50de-4adc-9673-6a8008892c21/resourceGroups/b1e3-gr1/providers/Microsoft.DBforPostgreSQL/servers/b1e3-gr1-postgres-server"
#           ],
#           "timeContext" : {
#             "durationMs" : 1800000
#           },
#           "metrics" : [
#             {
#               "namespace" : "microsoft.dbforpostgresql/servers",
#               "metric" : "microsoft.dbforpostgresql/servers-Saturation-backup_storage_used",
#               "aggregation" : 4,
#               "splitBy" : null,
#               "columnName" : "Backup storage "
#             }
#           ],
#           "gridSettings" : {
#             "rowLimit" : 10000
#           }
#         },
#         "name" : "métrique - 2"
#       },
#       {
#         "type" : 10,
#         "content" : {
#           "chartId" : "workbook6c43fe94-6262-4c2b-8238-638a0950af10",
#           "version" : "MetricsItem/2.0",
#           "size" : 0,
#           "chartType" : 2,
#           "resourceType" : "microsoft.storage/storageaccounts",
#           "metricScope" : 0,
#           "resourceIds" : [
#             "/subscriptions/c56aea2c-50de-4adc-9673-6a8008892c21/resourceGroups/b1e3-gr1/providers/Microsoft.Storage/storageAccounts/b1e3gr1sa"
#           ],
#           "timeContext" : {
#             "durationMs" : 3600000
#           },
#           "metrics" : [
#             {
#               "namespace" : "microsoft.storage/storageaccounts",
#               "metric" : "microsoft.storage/storageaccounts-Capacity-UsedCapacity",
#               "aggregation" : 4,
#               "splitBy" : null
#             }
#           ],
#           "gridSettings" : {
#             "rowLimit" : 10000
#           }
#         },
#         "name" : "métrique - 3"
#       }
#     ],
#     "fallbackResourceIds" : [
#       "c56aea2c-50de-4adc-9673-6a8008892c21"
#     ],
#     "$schema" : "https://github.com/Microsoft/Application-Insights-Workbooks/blob/master/schema/workbook.json"
#   })

# }

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



