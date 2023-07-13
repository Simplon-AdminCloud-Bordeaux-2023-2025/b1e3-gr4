#Gestion du fichier inventory.ini
resource "null_resource" "rminventory" {
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = "rm -f ./ansibleplaybooks/inventory.ini"
  }
}

resource "null_resource" "inventory" {
  depends_on = [null_resource.rminventory]
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = <<EOT
    echo "[bastion]" >> ./ansibleplaybooks/inventory.ini;
    echo ${azurerm_public_ip.ipBastion.ip_address}>> ./ansibleplaybooks/inventory.ini;
    echo " " >> ./ansibleplaybooks/inventory.ini;
    echo "[bastion:vars]" >> ./ansibleplaybooks/inventory.ini;
    echo "ansible_port = 22" >> ./ansibleplaybooks/inventory.ini;
    echo "ansible_user="${local.user}"" >> ./ansibleplaybooks/inventory.ini;
    echo "ansible_ssh_private_key_file="${local.path_to_private_key}"">> ./ansibleplaybooks/inventory.ini;
    echo " " >> ./ansibleplaybooks/inventory.ini;
    echo "[app]" >> ./ansibleplaybooks/inventory.ini;
    echo "${azurerm_network_interface.nicApp.private_ip_address}" >> ./ansibleplaybooks/inventory.ini;
    echo " " >> ./ansibleplaybooks/inventory.ini;
    echo "[app:vars]" >> ./ansibleplaybooks/inventory.ini;
    echo "ansible_port = 22" >> ./ansibleplaybooks/inventory.ini;
    echo "ansible_user="${local.user}"">> ./ansibleplaybooks/inventory.ini;
    echo "ansible_ssh_private_key_file="${local.path_to_private_key}"" >> ./ansibleplaybooks/inventory.ini;
    echo ansible_ssh_common_args=\'-o StrictHostKeyChecking=no -o ProxyCommand=\"ssh -W %h:%p -q ${local.user}@${azurerm_public_ip.ipBastion.ip_address}\"\' >> ./ansibleplaybooks/inventory.ini
    EOT
  }
}

#Gestion du playbook config_wikijs
resource "null_resource" "rmconfig_wikijs" {
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = "rm -f ./ansibleplaybooks/wikijs/roles/commun/defaults/main.yml"
  }
}

resource "null_resource" "config_wikijs" {
  depends_on = [null_resource.rmconfig_wikijs]
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = <<EOT
    echo "---" >> ./ansibleplaybooks/wikijs/roles/commun/defaults/main.yml;
    echo "vaultname: "${azurerm_key_vault.keyVault.name}"" >> ./ansibleplaybooks/wikijs/roles/commun/defaults/main.yml;
    echo "vaultsecretname: "${azurerm_key_vault_secret.passworddatabase.name}"" >> ./ansibleplaybooks/wikijs/roles/commun/defaults/main.yml;
    echo "tenantid: ${data.azurerm_client_config.current.tenant_id}" >> ./ansibleplaybooks/wikijs/roles/commun/defaults/main.yml;
    echo " " >> ./ansibleplaybooks/wikijs/roles/commun/defaults/main.yml;
    echo "hostdb: ${azurerm_mariadb_server.dbserver.fqdn}"  >> ./ansibleplaybooks/wikijs/roles/commun/defaults/main.yml;
    echo "userdb: ${local.dbuser}@${azurerm_mariadb_server.dbserver.name}"  >> ./ansibleplaybooks/wikijs/roles/commun/defaults/main.yml;
    echo "dbname: ${azurerm_mariadb_database.database.name}"  >> ./ansibleplaybooks/wikijs/roles/commun/defaults/main.yml
    EOT
  }
}

#Gestion du playbook adduser
resource "null_resource" "rmadduser" {
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = "rm -f ./ansibleplaybooks/configmariadb/roles/commun/defaults/main.yml"
  }
}

resource "null_resource" "adduser" {
  depends_on = [null_resource.rmadduser]
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = <<EOT
    echo "---" >> ./ansibleplaybooks/configmariadb/roles/defaults/main.yml;
    echo "vaultname: "${azurerm_key_vault.keyVault.name}"" >> ./ansibleplaybooks/configmariadb/roles/commun/defaults/main.yml;
    echo "vaultsecretnameuser: "${azurerm_key_vault_secret.passworddatabaseuser.name}"" >> ./ansibleplaybooks/configmariadb/roles/commun/defaults/main.yml;
    echo "vaultsecretnameadmin: "${azurerm_key_vault_secret.passworddatabase.name}"" >> ./ansibleplaybooks/configmariadb/roles/commun/defaults/main.yml;
    echo "tenantid: ${data.azurerm_client_config.current.tenant_id}" >> ./ansibleplaybooks/configmariadb/roles/commun/defaults/main.yml;
    echo " " >> ./ansibleplaybooks/configmariadb/roles/commun/defaults/main.yml;
    echo "hostdb: ${azurerm_mariadb_server.dbserver.fqdn}"  >> ./ansibleplaybooks/configmariadb/roles/commun/defaults/main.yml;
    echo "userdb: ${local.dbuser}@${azurerm_mariadb_server.dbserver.name}"  >> ./ansibleplaybooks/configmariadb/roles/commun/defaults/main.yml;
    echo "admindb: ${local.dbserveradmin}@${azurerm_mariadb_server.dbserver.name}"  >> ./ansibleplaybooks/configmariadb/roles/commun/defaults/main.yml;
    echo "dbname: ${azurerm_mariadb_database.database.name}"  >> ./ansibleplaybooks/configmariadb/roles/commun/defaults/main.yml
    EOT
  }
}

#Gestion du playbook mountshare
resource "null_resource" "rmmountshare" {
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = "rm -f ./ansibleplaybooks/mountshare/roles/commun/defaults/main.yml"
  }
}

resource "null_resource" "mountshare" {
  depends_on = [null_resource.rmmountshare]
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = <<EOT
    echo "---" >> ./ansibleplaybooks/mountshare/roles/commun/defaults/main.yml;
    echo "mountpoint: /wikijs" >> ./ansibleplaybooks/mountshare/roles/commun/defaults/main.yml;
    echo "username: ${azurerm_storage_account.staccount.name}" >> ./ansibleplaybooks/mountshare/roles/commun/defaults/main.yml;
    echo "share_name: ${azurerm_storage_share.share.name}" >> ./ansibleplaybooks/mountshare/roles/commun/defaults/main.yml;
    echo "password: pass" >> ./ansibleplaybooks/mountshare/roles/commun/defaults/main.yml
     EOT
  }
}