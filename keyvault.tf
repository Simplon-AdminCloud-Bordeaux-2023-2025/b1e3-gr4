#Create key vault
resource "azurerm_key_vault" "keyVault" {
  name                     = "${local.prefixName}-kv-${random_integer.random.result}"
  location                 = data.azurerm_resource_group.rg.location
  resource_group_name      = data.azurerm_resource_group.rg.name
  tenant_id                = data.azurerm_client_config.current.tenant_id
  purge_protection_enabled = false
  sku_name                 = "standard"

}

#Get current azure user informations
data "azurerm_client_config" "current" {}

#Create access policy for current user
resource "azurerm_key_vault_access_policy" "terraform_user" {
  key_vault_id = azurerm_key_vault.keyVault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  secret_permissions = [
    "Delete", "Get", "Purge", "Recover", "Restore", "Set", "List", "Backup"
  ]

  certificate_permissions = [
    "Delete", "Get", "Purge", "Recover", "Restore", "SetIssuers", "List", "Backup", "Import"
  ]

  key_permissions = [
    "Delete", "Get", "Purge", "Recover", "Restore", "Create", "List", "Backup", "Import", "Decrypt", "Encrypt"
  ]
}

#Create access policy for other user
resource "azurerm_key_vault_access_policy" "other_user" {
  key_vault_id = azurerm_key_vault.keyVault.id
  tenant_id    = "a2e466aa-4f86-4545-b5b8-97da7c8febf3"
  object_id    = "0a4b1439-ad32-4cc4-8867-8f91b8f7bc49"

  secret_permissions = [
    "Delete", "Get", "Purge", "Recover", "Restore", "Set", "List", "Backup"
  ]

  certificate_permissions = [
    "Delete", "Get", "Purge", "Recover", "Restore", "SetIssuers", "List", "Backup", "Import"
  ]

  key_permissions = [
    "Delete", "Get", "Purge", "Recover", "Restore", "Create", "List", "Backup", "Import", "Decrypt", "Encrypt"
  ]
}

#Add
resource "azurerm_key_vault_secret" "ssh_public_key" {
  key_vault_id = azurerm_key_vault.keyVault.id
  name         = "ssh-public"
  value        = local.ssh_pub_key
  depends_on   = [azurerm_key_vault_access_policy.terraform_user, azurerm_key_vault_access_policy.other_user]
}

#Add random generated password for database server administrator to key vault
resource "azurerm_key_vault_secret" "passworddatabase" {
  key_vault_id = azurerm_key_vault.keyVault.id
  name         = local.dbserveradmin
  value        = random_password.dbpass.result
  depends_on   = [azurerm_key_vault_access_policy.terraform_user, azurerm_key_vault_access_policy.other_user]
}

#Add random generated password for database user to key vault
resource "azurerm_key_vault_secret" "passworddatabaseuser" {
  key_vault_id = azurerm_key_vault.keyVault.id
  name         = local.dbuser
  value        = random_password.dbpassuser.result
  depends_on   = [azurerm_key_vault_access_policy.terraform_user, azurerm_key_vault_access_policy.other_user]
}

#Add storage account (smb) access key to key vault - will be retrieved by ansibleplaybooks
resource "azurerm_key_vault_secret" "filesharekey" {
  key_vault_id = azurerm_key_vault.keyVault.id
  name         = "${azurerm_storage_account.staccount.name}-accessKey"
  value        = azurerm_storage_account.staccount.primary_access_key
  depends_on   = [azurerm_key_vault_access_policy.terraform_user, azurerm_key_vault_access_policy.other_user]
}

#Add storage account (blob) access key to key vault - will be retrieved by ansibleplaybooks
resource "azurerm_key_vault_secret" "containerkey" {
  key_vault_id = azurerm_key_vault.keyVault.id
  name         = "${azurerm_storage_account.staccount2.name}-accessKey"
  value        = azurerm_storage_account.staccount2.primary_access_key
  depends_on   = [azurerm_key_vault_access_policy.terraform_user, azurerm_key_vault_access_policy.other_user]
}

#Add application certificate to key vault with alert rule 
# resource "azurerm_key_vault_certificate" "certificatwikijs" {
#   name         = "wikicert"
#   key_vault_id = azurerm_key_vault.keyVault.id
#   depends_on   = [azurerm_key_vault_access_policy.terraform_user, azurerm_key_vault_access_policy.other_user]
#   certificate {
#     contents = filebase64("./ansibleplaybooks/challengeHTTP/roles/cert.pfx")
#     password = "challengepassword"
#   }
#   certificate_policy {
#     issuer_parameters {
#       name = "Unknown"
#     }
#     lifetime_action {
#       action {
#         action_type = "EmailContacts"
#       }
#       trigger {
#         days_before_expiry = 7
#       }
#     }
#     secret_properties {
#       content_type = "application/x-pkcs12"
#     }
#     key_properties {
#       curve      = "P-256"
#       exportable = true
#       key_size   = 256
#       key_type   = "EC"
#       reuse_key  = true
#     }
#   }
# }


