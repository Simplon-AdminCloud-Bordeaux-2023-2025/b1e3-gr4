## [B1E3] - Déploiement d'une infrastructure avec Terraform et Ansible ##

#### Application Wiki.js avec une base de données MariaDB  ####

## Conditions d'utilisation ##
>
Ce dépôt regroupe plusieurs fichiers qui permettent l'automatisation d'un déploiement de l'application WikiJS.
Les fichiers utilisent les langages suivants :
-	Az CLI
-	Terraform 
-	Yaml

Pour exécuter cette installation, il est nécessaire d'avoir un abonnement Azure, un éditeur de code (type VSC), d'installer Azure CLI, Terraform et Ansible.

## Personnalisation du déploiement ##

* Commencez par récupérer le dépôt `git clone git@github.com:Simplon-AdminCloud-Bordeaux-2023-2025/b1e3-gr4.git`.

* Dans le fichier network.tf, sur le bloc locals, adaptez les variables à vos informations personnelles.

## Déploiement avec Terraform : ##

* Etape 1 : Initialisez le backend Terraform
>
<center> `cd b1e3-gr4` </center>

<center> `terraform init` </center>

* Etape 2 : Planifiez les ressources à déployer
>
<center> `terraform plan` </center>

* Etape 3 : Appliquez le plan pour créer les ressources
>
<center> `terraform apply` </center>

* Une fois le déploiement terminé, lancer le playbook challenge HTTP pour générer le certificat (depuis le dossier ansibleplaybooks)  :
<center> `ansible-playbook -i inventory.ini ./challengeHTTP/roles/runChallenge.yml`

* Dans les fichiers gateway.tf et keyvault.tf, décommentez les lignes 106 à 129 et 94 à 125, puis répéter les étapes 2 et 3.

## Lancement des playbooks pour l'installation de l'application sur la VM application (depuis le dossier ansibleplaybooks) 
>
<center> `ansible-playbook -i inventory.ini  ./mountshare/roles/mountshare.yml` </center>

<center> `ansible-playbook -i inventory.ini  ./configmariadb/roles/adduserwikijsdb.yml` </center>

<center> `ansible-playbook -i inventory.ini  ./wikijs/roles/installwikijs.yml` </center>


