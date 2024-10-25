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

* Dans le fichier provider.tf, à la ligne 17, adaptez la variable subscription_id à vos informations personnelles.

* Dans le fichier metric.tf, de la ligne 266 à 273, adaptez les blocs email_receiver à vos informations personnelles.

* Dans le fichier scaleset.tf, à la ligne 94, adaptez la variable custom_emails à vos informations personnelles.

* Pour l'ajout d'administrateurs sur les VM, personnalisez le fichier ./ansibleplaybooks/addusers/create-user.yml et ajoutez les clés publiques des nouveaux utilisateurs dans le même dossier.

* Connectez-vous à votre compte Azure avec votre terminal : `az login`

## Déploiement avec Terraform : ##

* Etape 1 : Initialisez le backend Terraform
>
                                              cd b1e3-gr4
>
                                          terraform init -upgrade

* Etape 2 : Planifiez les ressources à déployer
>
                                            terraform plan

* Etape 3 : Appliquez le plan pour créer les ressources
>
                                            terraform apply

* Une fois le déploiement terminé, lancer le playbook challenge HTTP pour générer le certificat (depuis le dossier ansibleplaybooks) :
>
                ansible-playbook -i inventory.ini ./challengeHTTP/roles/runChallenge.yml

* Dans les fichiers gateway.tf et keyvault.tf, décommentez les lignes 105 à 128 et 75 à 106, puis répétez les étapes 2 et 3.

## Lancement des playbooks pour l'installation de WikiJS sur la VM application (depuis le dossier ansibleplaybooks) 
>
  `ansible-playbook -i inventory.ini  ./mountshare/roles/mountshare.yml`
>
  `ansible-playbook -i inventory.ini  ./configmariadb/roles/adduserwikijsdb.yml`
>
  `ansible-playbook -i inventory.ini  ./wikijs/roles/installwikijs.yml`
>
  `ansible-playbook -i inventory.ini ./addusers/create-user.yml`

## Finalisation de l'installation

* Rendez-vous sur le lien : https://prefixName-wikijs.westeurope.cloudapp.azure.com pour créer votre compte administrateur WikiJS


