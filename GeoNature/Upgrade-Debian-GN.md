# Contexte

## Général

De nombreuses instances de GeoNature sont déployées sur des VPS sous Debian (Linux).  
Or, il faut parfois mettre à jour ce serveur d'une version stable de Debian vers une autre.  
Ce document précise les points de vigilance et les étapes nécessaires pour que cette mise à jour (MAJ) se passe au mieux.

## Cas spécifique 

Ce document a été réalisé dans le cas suivant :
- passage d'un serveur de Debian v11 à Debian v12
- avec la version 2.16.4 de GeoNature (+ UsersHub, Dashboard, Export, etc.) et Monitoring v1.2.4
- avec la version 1.3.3 de Citizen

# Points de vigilance

## PostgreSQL / PostGIS

Debian est livré avec une version par défaut de PosgreSQL.  
Mettre à jour Debian, c'est donc, aussi, mettre à jour PostgreSQL.

Or, à cause de PostGIS, cette MAJ ne pourra pas se faire simplement.  
En effet, la mise à jour des clusters de postgresql, normalement très facile (avec la fonction `pg_upgradecluster`) ne fonctionne pas.  
Il faut donc prendre ses précautions en faisant l'équivalent de cette fonction étape par étape, "à la main" :

### En amont de la MAJ Debian

- Faire un `dumpall` du cluster PostgreSQL ancien

### Après la MAJ Debian

- Télécharger PostGIS pour la nouvelle version de PostgreSQL téléchargée (car il n'est pas téléchargé tout seul). Par exemple pour debian 12, avec PostgreSQL version 15 : 
  ```bash
  sudo apt install postgresql-15-postgis
  ```
- Appliquer les modifications faites sur les fichiers de configurations de PostgreSQL (`postgresql.conf` et `pg_hba.conf`) et redémarrer le service PostgreSQL
- Vérifier que vous avez assez d'espace disponible sur votre serveur pour avoir "en double" la base. Autrement, supprimer l'ancien cluster (pour info, les clusters sont liés aux fichiers de configuration PostgreSQL, donc faites bien l'étape précédente avant !). Dans mon cas :
  ```bash
  sudo -u postgres pg_dropcluster --stop 13 main
  ```
- Vérifier que le data directory utilisé par le nouveau psql est le bon; autrement, vérifier votre fichier de configuration (en particulier, les numéros de port).
  ```bash
  sudo -u postgres -s
  psql 
  show data_directory;
  ```
- Restauration du dump complet (fichier généré par le dumpall)

## Environnements virtuels

Suite à la MAJ de Debian, il faut regénérer tous les environnements virtuels. Cela concerne :
- GeoNature
- Usershub
- Eventuellement, Citizen si vous l'avez déployé

Souvent, cela va consister à lancer ces commandes, dans les dossiers appropriés :
```bash
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

## Réinstallation de tous les modules

Suite à la MAJ de Debian, il faut réinstaller/MAJ tous les modules de GeoNature, avec les commandes suivantes :
```bash
source ~/geonature/backend/venv/bin/activate
# À faire pour monitorings, dashboard, exports, ...
geonature install-gn-module ~/gn_module_dashboard DASHBOARD
# Egalement relancer les commandes pour les modules en interne : Occtax, Occhab, Validation
geonature install-gn-module ~/geonature/contrib/gn_module_occhab OCCHAB --build FALSE
```
Puis relancer les services de GeoNature.
