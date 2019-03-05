## Scripts de migration Serena-2 vers GeoNature v2 ##

Par Xavier Arbez (PNR Pilat) - Janvier 2019

__IMPORTANT :__

L'ensemble des scripts présentés ici ont été produits dans un certain contexte d'utilisation de Serena et en vue d'un changement d'outil au profit de GeoNature v2.

Il est donc INDISPENSABLE de les exécuter manuellement et après avoir pris soin de faire les adaptations nécessaires pour qu'ils correspondent à votre BDD de départ et aux données qu'elle contient.
En particulier pour ce qui concerne :

* la création et l'attribution de métadonnées (cadres d'acquisitions, jeux de données, sources)
* la portabilité du référentiels d'utilisateurs (observateurs, déterminateur, valiateur et organismes rattachés)
* les correspondances de nomenclatures et de vocabulaires spécifiques à certains attributs.
* la gestion des géométries (format non-spatial et non-standard dans Serena), de leur types (point, polylignes, polygones) et de leur nature (précise, portée par un site, une commune, une maille etc.)

_Note :_ Avec ces adaptations dépendantes de votre contexte d'utilisation de Serena (pseudo-champ, gestion des utilisateurs, des géométries etc.) et la mise en place de triggers, il est possible de conserver Serena comme une source de données vivante qui alimente la synthèse de GeoNature.
Ce cas n'est pas documenté ici mais il l'est pour ObsOcc -> GeoNature par [@amandine-sahl](https://github.com/amandine-sahl) ici : [Import générique](https://github.com/PnX-SI/Ressources-techniques/tree/master/GeoNature/migration/generic)

-----------------------
### Procédure : ###

1. Les scripts sont à exécuter dans l'ordre de numérotation des fichiers,
2. Les préfixes *_serenadb__* et *_gn2db__* indiquent si les scripts doivent être joués dans la BDD de Serena ou de GeoNature,
3. Un script pour faire correspondre et/ou peupler le référentiel d'utilisateurs de GeoNature avec celui de Serena reste à produire --> Non traité pour notre cas car référentiel de départ et gestion des utilisateurs à revoir,
4. Les script 6.x sont optionnels et donne un exemple d'intégration de référentiels géographiques dans GeoNature (zonages espaces naturels INPN).

_Note :_ Prenez soin de lire les commentaires qui jalonnent les différents scripts. 
Certains blocs de SQL contiennent des requêtes de type SELECT qui peuvent servir à étudier et/ou contrôler des tables et des relations avant une opération plus impactante (INSERT, UPDATE, DELETE).

### [IMPORTANT] Pré-requis : ###


L'exemple de migration documenté ici implique que votre base de données Serena soit dans PostGreSQL et non plus dans un format de fichier Access (.mdb).

Pour ce faire, se reporter à la documentation officielle de Serena dans laquelle la procédure est décrite ainsi qu'au étapes décrites ci-dessous.

#### Migration BDD Access Serena vers PostGreSQL ####
-----------------------

L’objectif est d’intégrer une base de données issues de Serena2 et depuis une base de données Access (.mdb) vers une BDD PostGreSQL/PostGIS puis, dans la synthèse de GeoNature v2.

#### Plusieurs grandes étapes : ####

* Migrer la base de données initiale au format .mdb (MS Access) vers le SGBD PostgreSQL
* Manipuler et restructurer les données qu’elle contient pour les intégrer à GeoNature
 

#### Préparation de la BDD PostGreSQL pour Serena ####

On commence par créer une base de données distincte pour Serena mais pour ce faire nous avons besoin d’utiliser un rôle PostgreSQL avec des droits SUPERUSER.

Lors de l’installation packagée de GeoNature (install_all.sh), la création d’un tel rôle n’est pas configurée. Le seul rôle SUPERUSER existant et le rôle « postgres » mais aucun mot de passe ne lui a été attribué.

On se connecte donc en SSH à notre serveur avec le role « geonatureadmin » (on autre selon ce qui a été défini lors de l’installation) et on lance les commandes suivantes en remplaçant ‘monpassachanger’ par le mdp de son choix et en utilisant ‘sudo’ :

On défini un MDP pour le rôle « postgres » :

	sudo -n -u postgres -s psql -c "ALTER USER postgres PASSWORD 'monpassachanger';"
On crée un rôle spécifique pour Serena :

	sudo -n -u postgres -s psql -c "CREATE ROLE serenadmin WITH LOGIN PASSWORD 'monpassachanger';"

On crée la base de données pour Serena, on donne des droits au rôle « geonatadmin » sur cette BDD et on y ajoute des extensions :

	sudo -n -u postgres -s createdb -O serenadmin serenadb

	sudo -n -u postgres -s psql -d serenadb -c "CREATE EXTENSION IF NOT EXISTS postgis;"
	sudo -n -u postgres -s psql -d serenadb -c "CREATE EXTENSION IF NOT EXISTS hstore;"
	sudo -n -u postgres -s psql -d serenadb -c "CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog; COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';"
	sudo -n -u postgres -s psql -d serenadb -c 'CREATE EXTENSION IF NOT EXISTS "uuid-ossp";'

On crée les 2 schémas nécessaire au fonctionnement de Serena :

	sudo -n -u postgres -s psql -d serenadb -c 'CREATE SCHEMA serenabase AUTHORIZATION serenadmin; GRANT USAGE ON SCHEMA serenabase TO geonatadmin;'

	sudo -n -u postgres -s psql -d serenadb -c 'CREATE SCHEMA serenarefe AUTHORIZATION serenadmin; GRANT USAGE ON SCHEMA serenarefe TO geonatadmin;'

#### Migration des données ####

__Note__ : Il est nécessaire d'éxécuter cette procédure depuis une version de Serena disposant d'une licence valide. Possible également depuis une verion démo mais en bricolant et non-documenté ici.
 
Suivre la procédure décrite dans la documentation de Serena pour créer les tables et y copier les données depuis l’interface de Serena (synthétisée ici) :

A l’aide d’un éditeur de texte, créer un nouveau fichier et enregistrez-le (par exemple dans C:\Serena2Data) en le nommant et en définissant l’extension en « .pgweb« . C’est ce fichier qui contiendra les informations de connexions à PostgreSQL et qui sera utilisé par Serena.

Ajouter ce contenu dans le fichier, adapter les variables à votre contexte (laisser serenabase comme Schema) et enregistrer les modifications :

	Server=ipduserveur;Port=port;User Id=nomduuserpostgresql;Password=passuserpostgresql;Database=nombdd;§Schema=serenabase;SSHLogin=monloginssh;SSHPassword=monpassssh;SSHPort=monportssh;


* Ouvrir la base de données à migrer avec le compte « admin »
* Aller dans le menu ‘Gestion des bases’ >> ‘Migration vers une base PostgreSQL’
* Copier la chaîne de connexion telle que définie précédemment dans le fichier « .pgweb » dans le champ prévu

#### Création des tables ####
* Cocher ‘Créer les tables du schéma’
* Saisir TOUT dans le champ ‘Paramètre de l’action’
* Lancer l’action et patienter jusqu’à la fin de l’opération (création de la structure des tables du schéma ‘serenabase’)
* Modifier la valeur du champ ‘Paramètre de l’action’ avec REF
* Lancer l’action et patienter jusqu’à la fin de l’opération (création de la structure des tables du schéma ‘serenarefe’)

#### Peuplement des tables ####
* Cocher ‘Copier des tables de la base ouverte ici’
* Saisir TOUT dans le champ ‘Paramètre de l’action’
* Lancer l’action et patienter jusqu’à la fin de l’opération (peuplement des tables du schéma ‘serenabase’)
* Modifier la valeur du champ ‘Paramètre de l’action’ avec REF
* Lancer l’action et patienter jusqu’à la fin de l’opération (peuplement des tables du schéma ‘serenarefe’)

Pour vérifier que tout c’est bien déroulé, se connecter à la base de données ‘serenadb’ avec pgAdmin et vérifier que les tables sont bien peuplées.

Ensuite il faut vérifier que Serena peut se connecter à la base PG à l’aide du fichier .pgweb crée précédemment :

* Ouvrir Serena et sur la première fenêtre de connexion, cliquer sur ‘Ouvrir une autre base’ en haut à gauche.
* Sélectionner le fichier .pgweb (normalement dans : C:\Serena2Data\).

Donner les droits au rôle « geonatadmin » sur l’ensemble des tables des schémas « serenabase » et « serenarefe » :
	
	sudo -n -u postgres -s psql -d serenadb -c 'GRANT SELECT ON ALL TABLES IN SCHEMA serenabase, serenarefe TO geonatadmin;'

#### Connexion à la BDD PostGreSQL avec Serena ####

* Ouvrir Serena2 et cliquer sur le menu "Ouvrir une autre base" (en haut à gauche de la fenêtre de connexion)

* Sélectionner le fichier .pg_web crée précédemment et valider

* Essayer de vous connecter avec son login et mdp Serena

Si la connexion fonctionne et que la base se charge sans message d’erreur : BINGO !

Dans tout les cas, il faudra faire des tests plus approfondis pour vérifier les transactions de Serena vers PG, les modifications dans la BDD lors des mises à jour etc… 