## [B1E3] - Déploiement d'une infrastructure avec Terraform et Ansible ##

#### Application Wiki.js avec une base de données MariaDB  ####


## Déploiement avec Terraform : ##

* Initialisez le backend Terraform :
``` cd b1e3-gr4 ```
  ```terraform init ```

*  Planifiez les ressources à déployer :
``` terraform plan ```

* Appliquez le plan pour créer les ressources :
 ``` terraform apply ```




## Lancement des playbooks (depuis le dossier ansibleplaybooks) 
>
`ansible-playbook -i inventory.ini  ./mountshare/roles/mountshare.yml`
>
`ansible-playbook -i inventory.ini  ./configmariadb/roles/adduserwikijsdb.yml`
>
`ansible-playbook -i inventory.ini  ./wikijs/roles/installwikijs.yml`
>
>



## Finaliser le lancement de l'application
>
Se connecter en ssh au serveur d'application
>
Depuis le dossier ~/wiki, lancer la commande
`sudo node server`\
Attendre que le message indiquant que le site est disponible s'affiche et s'y connecter avec un navigateur web
