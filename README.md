# B1e3-gr4

## [B1E3] - Déploiement d'une infrastructure avec Terraform et Ansible ##

![Brief_Terraform](https://github.com/Simplon-AdminCloud-Bordeaux-2023-2025/b1e3-gr4/assets/71389760/18a43002-8c35-47c5-86b8-9bd83b038b92)


## Lancement des playbooks (depuis le dossier ansibleplaybooks) 
>
`ansible-playbook -i inventory.ini  ./mountshare/roles/mountshare.yml`
>
`ansible-playbook -i inventory.ini  ./configmariadb/roles/adduserwikijsdb.yml`
>
`ansible-playbook -i inventory.ini  ./wikijs/roles/installwikijs.yml`

## Finaliser le lancement de l'application
>
Se connecter en ssh au serveur d'application
>
Depuis le dossier ~/wiki, lancer la commande
`sudo node server`\
Attendre que le message indiquant que le site est disponible s'affiche et s'y connecter avec un navigateur web