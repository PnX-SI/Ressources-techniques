# Borg
Créée le jeudi 18 mars 2021

### Installer Borgmatic

sudo su -
apt install borgbackup
pip3 install --user borgmatic

echo export 'PATH="$PATH:/root/.local/bin"' >> ~/.bashrc
source ~/.bashrc

### Générer un exemple de conf

`generate-borgmatic-config`
-> crée un conf par défaut dans `/etc/borgmatic/`
Voir la conf d'exemple à la fin de cette doc
et la remplir.
Mettre une pass phrase dans  "storage" / "encryption_passphrase:"

### Connexion entre la VM et le backupOVH via monitoring


* Créer un répertoire pour accueillir les backups (le même qui est utilisé dans la config borgmatic, rubrique repositories
* Générer une clé ssh sur la VM source : 
	* ssh-keygen -t ed25519
* Ajouter cette clé dans ."ssh/autohorized_keys" de la machine hote des sauvegarde
* command="borg serve --restrict-to-repository <BACKUP_REPO>",restrict ssh-ed25519 <MY_SSH_KEY>



### Initaliser le repo borg
su la machine source
borgmatic init --encryption authenticated-blake2


* Les backups ne sont pas "crypté' mais simplement protégé par un mdp (passphrase):



### Configuration du "hook" de sauvegarde postgresql
Les paramètres sont dans la section "postgresql_databases"
**Deux cas usages sont possible:**

* sauvegarder l'ensemble des BDD: paramètre "name" = all et "username" = postgres
* sauvegarder les DB individuellement : paramètre "name" = <DB_NAME> , "username" = postgres

Il est possible de faire la sauvegarde avec l'utilisateur propriétaire de la base, mais celui-ci n'est souvent pas superutilisateur et ne pourra pas créer d'extention.
Nos sauvegarde sont faite avec l'utilisateur postgres, ce qui necessite d'autoriser une connection à la socket sans mdp pour l'utilisateur postgres (voir ci dessous)

Dans le 1er cas il s'agira d'un dump en "plain SQL", dans le second on peut choisir le format (voir doc pg_dump). 


* Editer le fichier pg_hba.conf pour permettre à l'utilisateur postgres de se connecter à la socket sans authentification : 

local   all             postgres                                trust

* Editer le fichier postgresql.conf

unix_socket_permissions = 0700   
-> seul l'utilisateur postgre peut se connecter à la socket
Dans le cas 2, après avoir renseigner le mdp dans la conf borgmatic, il faut également éditer le fichier pg_hba.conf pour autoriser une connexion "md5" pour la base et l'utilisateur qui fait le backup
Bien mettre cette ligne au dessus du "local   all             all                                     peer" déjà existant
local   <DB_NAME>      <USER>                                  md5



### Créer un cron pour executer Borg

Dans `/etc/cron.d` créer un fichier borgmatic et y ajouter le cron:
0 3 * * * root PATH=$PATH:/usr/bin:/usr/local/bin /root/.local/bin/borgmatic --syslog-verbosity 1
Ceci execute la commande "borgmatic" toute les nuit à 3h du matin


### Extraire une archive


* Lister l'ensemble des archives d'un répo

borg list <REPO_PATH>

* L'extraire:

::

    borg extract <REPO_PATH::ARCHIVE_NAME>
    borg extract [<BORG_REPO>::geonature2-2021-03-18T16:17:01.702566]

NB : pour trouver le nom de l'archive faire un `borg list .` depuis le repertoire borg.

* Au cas ou Borg échoue à créer/acquérir un verrou : borg break-lock <repo>

	

### Restaurer une archive de BDD

*Cas d'usage: restaurer un backup de BDD sur la preprod*

* Installer borg et borgmatic sur la machine
* Copier le fichier de conf /etc/borgmatic/config.yaml de GeoNature sur la preprod (mettre le paramètre unknown_unencrypted_repo_access_is_ok:true)
* Générer une clé SSH et la mettre sur monitoring  et la mettre dans le autorized_key de minitoring (voir plus haut)
* Editer le fichier pg_hba.conf pour permettre à l'utilisateur postgres de se connecter à la socket sans authentification : 

::

    local   all             postgres                                trust
	

* borg list (pour lister les repo connecté)
* Mettre la passphrase
* borgmatic restore --archive latest --database <database_name> -v 2

si --database est absent: restaure toutes les db



### Restaurer toute la machine

Voir (Restaurer une archive de BDD pour la conf)
Retirer le autorized key sur le serveur monitoring car sinon a le droit d efaire seulement un "borg serve"
mettre `relocated_repo_access_is_ok: true` dans la conf borgmatic

Depuis la racine du serveur: restaurer uniquement le "/home"

* borgmatic extract --archive latest --progress --path home

 Attention: ne pas mettre le / initial pour le path et bien se mettre à l'endroit ou on veux restaurer les fichier: "/" ou "/var" ...


### Récupérer uniquement le backup postgresql

Les backup postgresql sont stockés ici: 
/root/.borgmatic/postgresql_databases/localhost/all



## Parametrer des "hook" post-sauvegarde

Borgmatic permet de paramétrer des hooks: actions à executer avant, après ou en cas d'erreur de la sauvegarde.
Dans notre cas on choisit d'envoyer un mail en cas de succès et d'erreur de la sauvegarde.
Le script `notify.sh` du repertoire fournit un exemple d'envoi par email (necessite d'avoir installé un relay mail type postfix sur la machine).
Borgmatic fournit des variable `error` `output` et `repository` qui permette d'en savoir plus sur les eventuels erreurs lors des sauvegardes.