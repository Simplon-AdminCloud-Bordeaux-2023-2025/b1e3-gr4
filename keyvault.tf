resource "azurerm_key_vault" "keyVault" {
  name                     = "${local.prefixName}-kv-${random_integer.random.result}"
  location                 = data.azurerm_resource_group.rg.location
  resource_group_name      = data.azurerm_resource_group.rg.name
  tenant_id                = data.azurerm_client_config.current.tenant_id
  purge_protection_enabled = false
  sku_name                 = "standard"

}

data "azurerm_client_config" "current" {}

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


resource "azurerm_key_vault_secret" "ssh_public_key" {
  key_vault_id = azurerm_key_vault.keyVault.id
  name         = "ssh-public"
  value        = local.ssh_pub_key
  depends_on   = [azurerm_key_vault_access_policy.terraform_user]
}

resource "azurerm_key_vault_secret" "passworddatabase" {
  key_vault_id = azurerm_key_vault.keyVault.id
  name         = local.dbserveradmin
  value        = random_password.dbpass.result
  depends_on   = [azurerm_key_vault_access_policy.terraform_user]
}

resource "azurerm_key_vault_secret" "passworddatabaseuser" {
  key_vault_id = azurerm_key_vault.keyVault.id
  name         = local.dbuser
  value        = random_password.dbpassuser.result
  depends_on   = [azurerm_key_vault_access_policy.terraform_user]
}

resource "azurerm_key_vault_secret" "filesharekey" {
  key_vault_id = azurerm_key_vault.keyVault.id
  name         = "${azurerm_storage_account.staccount.name}-accessKey"
  value        = azurerm_storage_account.staccount.primary_access_key
  depends_on   = [azurerm_key_vault_access_policy.terraform_user]
}

resource "azurerm_key_vault_secret" "containerkey" {
  key_vault_id = azurerm_key_vault.keyVault.id
  name         = "${azurerm_storage_account.staccount2.name}-accessKey"
  value        = azurerm_storage_account.staccount2.primary_access_key
  depends_on   = [azurerm_key_vault_access_policy.terraform_user]
}

# resource "azurerm_key_vault_certificate" "certificatwikijs" {
#   name         = "wikijscertificat"
#   key_vault_id = azurerm_key_vault.keyVault.id
#   depends_on   = [azurerm_key_vault_access_policy.terraform_user, null_resource.playbookchallengehttp]
#   certificate {
#     contents = filebase64("./ansibleplaybooks/challengeHTTP/roles/cert.pfx")
#     password = "challengepassword"
#   }
    # lifetime_action {
    #   action {
    #     action_type = "EmailContacts"
    #   }
    #   trigger {
    #     days_before_expiry = 7
    #   }
    # }
# }


