# Création du workspace Azure Monitor
resource "azurerm_log_analytics_workspace" "workspace" {
  name                = "monitoring-workspace"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

# Activation de la surveillance de la machine virtuelle dans Azure Monitor
resource "azurerm_monitor_diagnostic_setting" "vm_monitoring" {
  name                       = "${local.prefixName}vm-monitoring"
  target_resource_id         = azurerm_linux_virtual_machine.app.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.workspace.id
  enabled_log {
    category = "LinuxSyslog"
    
  }
  enabled_log {
    category = "Metrics"
   
  }
}

# Activation de la surveillance de la base de données MariaDB dans Azure Monitor
resource "azurerm_monitor_diagnostic_setting" "db_monitoring" {
  name                       = "${local.prefixName}db-monitoring"
  target_resource_id         = azurerm_mariadb_server.dbserver.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.workspace.id
  enabled_log {
    category = "MySqlSlowLogs"
    
  }
  enabled_log {
    category = "MySqlGeneralLogs"
   
  }
  enabled_log {
    category = "MySqlErrorLogs"
    
  }
  enabled_log {
    category = "MySqlQueryStoreLogs"
    
  }
  enabled_log {
    category = "MySqlAuditLogs"
    
  }
  enabled_log {
    category = "MySqlBinLogs"
    
  }
  enabled_log {
    category = "Metrics"
 
  }
}

# Activation de la surveillance de l'espace de stockage dans Azure Monitor
resource "azurerm_monitor_diagnostic_setting" "storage_monitoring" {
  name                       = "${local.prefixName}storage-monitoring"
  target_resource_id         = azurerm_storage_account.staccount.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.workspace.id
  enabled_log {
    category = "StorageRead"
   
  }
  enabled_log {
    category = "StorageWrite"
    
  }
  enabled_log {
    category = "StorageDelete"
   
  }
  enabled_log {
    category = "StorageAction"
   
  }
  enabled_log {
    category = "Metrics"
   
  }
}


# Création d'une alerte en cas d'indisponibilité de l'application
resource "azurerm_monitor_scheduled_query_rules_alert" "app_unavailability_alert" {
  name                = "${local.prefixName}app-unavailability-alert"
  resource_group_name = data.azurerm_resource_group.rg.name
  description         = "Alert when application is unavailable"
  severity            = 2

  data_source_id = azurerm_monitor_log_profile.log_profile.id
  time_window    = "PT5M"

  query {
    query = <<QUERY
AppAvailability
| where Success == false
| summarize total_failures = count() by Computer, _ResourceId
QUERY
  }

  trigger {
    operator  = "GreaterThan"
    threshold = 0
    time_range {
      from = "PT5M"
      to   = "PT10M"
    }
  }

  action {
    action_group_id = azurerm_monitor_action_group.notification_group.id
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
    metric_namespace  = "Microsoft.Compute/virtualMachines"
    metric_name       = "Percentage CPU"
    aggregation       = "Average"
    operator          = "GreaterThan"
    threshold         = 90

    dimension {
      name     = "InstanceId"
      operator = "Include"
      values   = [azurerm_linux_virtual_machine.app.id]
    }
  }

  action {
    action_group_id = azurerm_monitor_action_group.notification_group.id
  }
}


# Création d'une alerte si la date d'expiration du certificat TLS est inférieure à 7 jours

resource "azurerm_monitor_metric_alert" "certificate_expiry_alert" {
  name                = "${local.prefixName}certificate-expiry-alert"
  resource_group_name = data.azurerm_resource_group.rg.name
  description         = "Alert when TLS certificate expiry is less than 7 days"
  severity            = 2

  scopes = [azurerm_linux_virtual_machine.app.id]

  criteria {
    metric_namespace = "Microsoft.Security/certificates"
    metric_name      = "Certificate Expiry Date"
    aggregation      = "Maximum"
    operator         = "LessThan"
    threshold        = 7

    dimension {
      name     = "certificateName"
      operator = "Include"
      values   = ["certificategr4"]
    }
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

  scopes = [azurerm_storage_account.staccount.id]

  criteria {
    metric_namespace = "Microsoft.Storage/storageAccounts"
    metric_name      = "UsedCapacity"
    aggregation      = "Maximum"
    operator         = "LessThan"
    threshold        = 10

    dimension {
      name     = "ResourceId"
      operator = "Include"
      values   = [azurerm_storage_account.staccount.id]
    }
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
    email_address = "dg.tauzin@whims-services.com"
  }
}



