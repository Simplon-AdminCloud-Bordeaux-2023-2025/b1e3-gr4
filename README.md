## [B1E3] - Déploiement d'une infrastructure avec Terraform et Ansible ##

#### Application Wiki.js avec une base de données MariaDB  ####




## Lancement des playbooks (depuis le dossier ansibleplaybooks) 
>
`ansible-playbook -i inventory.ini  ./mountshare/roles/mountshare.yml`
>
`ansible-playbook -i inventory.ini  ./configmariadb/roles/adduserwikijsdb.yml`
>
`ansible-playbook -i inventory.ini  ./wikijs/roles/installwikijs.yml`
>
>


#### Déploiement avec Terraform : ####

* Initialisez le backend Terraform :
``` cd b1e3-gr4 ```
  ```terraform init ```

*  Planifiez les ressources à déployer :
``` terraform plan ```

* Appliquez le plan pour créer les ressources :
 ``` terraform apply ```

 #### Automatisation avec Ansible : ####

 * Vérifiez que les machines virtuelles sont accessibles via SSH et mettez à jour le fichier d'inventaire Ansible inventory.ini avec les adresses IP des machines virtuelles.

* Exécutez le playbook Ansible pour automatiser l'installation et la configuration de l'application Wiki.js et du bastion :
``` ansible-playbook -i ansiblefiles/inventory.ini --user your_user --become ansiblefiles/sinstallwikijs.yml ```


#### Création d'utilisateurs avec Ansible ####

##### Personnalisation requise #####
 
 * Vous devez personnaliser les noms des utilisateurs selon vos besoins ainsi que le chemin de vos clé SSH


 ##### Commande Ansible à exécuter : #####

* Pour exécuter le fichier create-user.yml à l'aide d'Ansible, vous pouvez utiliser la commande suivante :

``` ansible-playbook -i ansiblefiles/inventory.ini --user your_user --become users/create-user.yml ```

## Finaliser le lancement de l'application
>
Se connecter en ssh au serveur d'application
>
Depuis le dossier ~/wiki, lancer la commande
`sudo node server`\
Attendre que le message indiquant que le site est disponible s'affiche et s'y connecter avec un navigateur web
