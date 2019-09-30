MIGRATION DE BASES ENTRE SERVEUR POSTGRESQL COMPORTANT DES VERSIONS POSTGIS DISTANTES
=====================================================================================


Adapter le contenu des 2 fichiers sample_*.sh à votre contexte et notamment les paramètres de connexion, nom des schémas et des tables à migrer. Prendre également soin de d'intégrer au script la création des extentions postgresql nécessaires au fonctionnement de la base.


Sur le serveur source
---------------------

Adapter le contenu du fichier sample_svgdb.sh au contenu de la base en tenant notamment compte des tables et vues contenues dans le schéma public
copier le fichier sample_svgdb.sh sur le serveur pg source (pg9.1 et postgis 1.5 pour l'example)

	scp -p 22 sample_svgdb.sh user@1.2.3.4:/home/MYLINUXUSER/

Se loguer sur ce serveur dans le home de MYLINUXUSER

	cd
	chmod +x sample_svgdb.sh
	sudo su postgres
	./sample_svgdb.sh

L'exécution de ce script va sauvegarder les schémas de la base, sans les fonctions postgis, dans un fichier sql dans répertoire /tmp/
Puis les envoyer avec la commande scp dans le /tmp/ du serveur PG de destination


Sur le serveur de cible
-----------------------

Copier le fichier sample_migratedb.sh sur le server pg de destination (pg11.5 postgis 2.5 pour l'example)
	
	scp -p 22 sample_migratedb.sh user@4.5.6.7:/home/MYLINUXUSER/

Se loguer sur ce serveur dans le home de MYLINUXUSER

Corriger les éventuelles fonctions postgis problématiques et notamment les 'ndims' et 'srid' à remplacer par 'st_ndims' et 'st_srid' dans /tmp/sample_public_schema.sql ainsi que dans tous les fichiers sql des schémas contenant des tables spatiales.
	
	nano /tmp/sample_public_schema.sql

Exécuter le script

	cd
	./sample_svgdb.sh

Vérifier que tout s'est bien passé dans le fichier de log 

	cat install.log

Vérifier la base du serveur de destination sur le nouveau serveur en y connectant son application et/ou en regardant le contenu depuis un outil de gestion de base de données.

