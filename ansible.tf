#Gestion du fichier inventory.ini
resource "null_resource" "inventory" {
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = <<EOT
    rm -f ./ansibleplaybooks/inventory.ini;
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
    echo ansible_ssh_common_args=\'-o StrictHostKeyChecking=no -o ProxyCommand=\"ssh -o StrictHostKeyChecking=no -W %h:%p -q ${local.user}@${azurerm_public_ip.ipBastion.ip_address}\"\' >> ./ansibleplaybooks/inventory.ini
    EOT
  }
}

#Gestion du playbook config_wikijs
resource "null_resource" "config_wikijs" {
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = <<EOT
    rm -f ./ansibleplaybooks/wikijs/roles/commun/defaults/main.yml;
    echo "---" >> ./ansibleplaybooks/wikijs/roles/commun/defaults/main.yml;
    echo "vaultname: "${azurerm_key_vault.keyVault.name}"" >> ./ansibleplaybooks/wikijs/roles/commun/defaults/main.yml;
    echo "vaultsecretname: "${azurerm_key_vault_secret.passworddatabaseuser.name}"" >> ./ansibleplaybooks/wikijs/roles/commun/defaults/main.yml;
    echo "tenantid: ${data.azurerm_client_config.current.tenant_id}" >> ./ansibleplaybooks/wikijs/roles/commun/defaults/main.yml;
    echo " " >> ./ansibleplaybooks/wikijs/roles/commun/defaults/main.yml;
    echo "hostdb: ${azurerm_mariadb_server.dbserver.fqdn}"  >> ./ansibleplaybooks/wikijs/roles/commun/defaults/main.yml;
    echo "userdb: ${local.dbuser}@${azurerm_mariadb_server.dbserver.name}"  >> ./ansibleplaybooks/wikijs/roles/commun/defaults/main.yml;
    echo "dbname: ${azurerm_mariadb_database.database.name}"  >> ./ansibleplaybooks/wikijs/roles/commun/defaults/main.yml;
    echo "dns: ${azurerm_public_ip.ipApp.fqdn}" >> ./ansibleplaybooks/wikijs/roles/commun/defaults/main.yml
    EOT
  }
}

#Gestion du playbook configmariadb
resource "null_resource" "adduser" {
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = <<EOT
    rm -f ./ansibleplaybooks/configmariadb/roles/commun/defaults/main.yml;
    echo "---" >> ./ansibleplaybooks/configmariadb/roles/commun/defaults/main.yml;
    echo "vaultname: "${azurerm_key_vault.keyVault.name}"" >> ./ansibleplaybooks/configmariadb/roles/commun/defaults/main.yml;
    echo "vaultsecretnameuser: "${azurerm_key_vault_secret.passworddatabaseuser.name}"" >> ./ansibleplaybooks/configmariadb/roles/commun/defaults/main.yml;
    echo "vaultsecretnameadmin: "${azurerm_key_vault_secret.passworddatabase.name}"" >> ./ansibleplaybooks/configmariadb/roles/commun/defaults/main.yml;
    echo "tenantid: ${data.azurerm_client_config.current.tenant_id}" >> ./ansibleplaybooks/configmariadb/roles/commun/defaults/main.yml;
    echo " " >> ./ansibleplaybooks/configmariadb/roles/commun/defaults/main.yml;
    echo "hostdb: ${azurerm_mariadb_server.dbserver.fqdn}"  >> ./ansibleplaybooks/configmariadb/roles/commun/defaults/main.yml;
    echo "userdb: ${local.dbuser}"  >> ./ansibleplaybooks/configmariadb/roles/commun/defaults/main.yml;
    echo "admindb: ${local.dbserveradmin}@${azurerm_mariadb_server.dbserver.name}"  >> ./ansibleplaybooks/configmariadb/roles/commun/defaults/main.yml;
    echo "dbname: ${azurerm_mariadb_database.database.name}"  >> ./ansibleplaybooks/configmariadb/roles/commun/defaults/main.yml
    EOT
  }
}

#Gestion du playbook mountshare
resource "null_resource" "mountshare" {
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = <<EOT
    rm -f ./ansibleplaybooks/mountshare/roles/commun/defaults/main.yml;
    echo "---" >> ./ansibleplaybooks/mountshare/roles/commun/defaults/main.yml;
    echo "vaultname: "${azurerm_key_vault.keyVault.name}"" >> ./ansibleplaybooks/mountshare/roles/commun/defaults/main.yml;
    echo "vaultsecretname: "${azurerm_key_vault_secret.filesharekey.name}"" >> ./ansibleplaybooks/mountshare/roles/commun/defaults/main.yml;
    echo "tenantid: ${data.azurerm_client_config.current.tenant_id}" >> ./ansibleplaybooks/mountshare/roles/commun/defaults/main.yml;
    echo " " >> ./ansibleplaybooks/mountshare/roles/commun/defaults/main.yml;
    echo "mountpoint: /wikijs" >> ./ansibleplaybooks/mountshare/roles/commun/defaults/main.yml;
    echo "username: ${azurerm_storage_account.staccount.name}" >> ./ansibleplaybooks/mountshare/roles/commun/defaults/main.yml;
    echo "share_name: ${azurerm_storage_share.share.name}" >> ./ansibleplaybooks/mountshare/roles/commun/defaults/main.yml;
    EOT
  }
}


#Gestion du playbook ChallengeHTTP
resource "null_resource" "challengehttp" {
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = <<EOT
    rm -f ./ansibleplaybooks/challengeHTTP/roles/commun/defaults/main.yml;
    echo "---" >> ./ansibleplaybooks/challengeHTTP/roles/commun/defaults/main.yml;
    echo "vaultname: "${azurerm_key_vault.keyVault.name}"" >> ./ansibleplaybooks/challengeHTTP/roles/commun/defaults/main.yml;
    echo "vaultsecretname: "${azurerm_key_vault_secret.containerkey.name}"" >> ./ansibleplaybooks/challengeHTTP/roles/commun/defaults/main.yml;
    echo "tenantid: ${data.azurerm_client_config.current.tenant_id}" >> ./ansibleplaybooks/challengeHTTP/roles/commun/defaults/main.yml;
    echo " " >> ./ansibleplaybooks/challengeHTTP/roles/commun/defaults/main.yml;
    echo "username: ${local.user}" >> ./ansibleplaybooks/challengeHTTP/roles/commun/defaults/main.yml;
    echo "storage_name: ${azurerm_storage_account.staccount2.name}" >> ./ansibleplaybooks/challengeHTTP/roles/commun/defaults/main.yml;
    echo "container_name: ${azurerm_storage_container.container.name}" >> ./ansibleplaybooks/challengeHTTP/roles/commun/defaults/main.yml;
    echo "dns: ${azurerm_public_ip.ipApp.fqdn}" >> ./ansibleplaybooks/challengeHTTP/roles/commun/defaults/main.yml;
    EOT
  }
}

# resource "null_resource" "playbookchallengehttp" {
#   depends_on = [azurerm_application_gateway.gw, null_resource.challengehttp, null_resource.inventory, azurerm_linux_virtual_machine.bastion, azurerm_linux_virtual_machine.app]
#   provisioner "local-exec" {
#     command = "ansible-playbook -i ./ansibleplaybooks/inventory.ini ./ansibleplaybooks/challengeHTTP/roles/runChallenge.yml"
#   }
# }

# resource "null_resource" "playbookconfigmariadb" {
#   depends_on = [null_resource.playbookchallengehttp, null_resource.adduser]
#   provisioner "local-exec" {
#     command = "ansible-playbook -i ./ansibleplaybooks/inventory.ini ./ansibleplaybooks/configmariadb/roles/adduserwikijsdb.yml"
#   }
# }

# resource "null_resource" "playbookmountshare" {
#   depends_on = [null_resource.playbookconfigmariadb, null_resource.mountshare]
#   provisioner "local-exec" {
#     command = "ansible-playbook -i ./ansibleplaybooks/inventory.ini ./ansibleplaybooks/mountshare/roles/mountshare.yml"
#   }
# }

# resource "null_resource" "playbookwikijs" {
#   depends_on = [null_resource.playbookmountshare, null_resource.config_wikijs]
#   provisioner "local-exec" {
#     command = "ansible-playbook -i ./ansibleplaybooks/inventory.ini ./ansibleplaybooks/wikijs/roles/installwikijs.yml"
#   }
# }

# resource "null_resource" "addusers" {
#   depends_on = [null_resource.playbookwikijs]
#   provisioner "local-exec" {
#     command = "ansible-playbook -i ./ansibleplaybooks/inventory.ini ./ansibleplaybooks/addusers/create-user.yml"
#   }
# } 