Script python de conversion de fichiers shapefiles en GeoPackages
=================================================================

Par Raphael Bres - Mars 2020

Le PNE a choisi de migrer ses fichiers SHP en GeoPackages (https://si.ecrins-parcnational.com/blog/2020-02-geojson-shapefile-geopackage.html).
Ce script permet d'automatiser la conversion des fichiers. 

Afin de réaliser la migration du format Shapefile vers le format GeoPackage sans problèmes, j’ai réalisé ce script en Python qui, en prenant un chemin comme paramètre, transforme un fichier Shapefile en fichier GeoPackage avant de supprimer tous les fichiers Shapefile.

Installation
------------

Cette fonction est récursive, ce qui veut dire que lorsqu’elle trouve un sous dossier dans le dossier passé en paramètre, la fonction se réexécute toute seule dans le sous dossier en question. Ce programme utilise deux modules en plus de ``Python 3`` qui sont ``os`` et ``Fiona`` (https://github.com/Toblerity/Fiona). Pour le module ``os``, il est normalement inclus dans l’installation de Python. Pour le module ``Fiona``, si ``pip`` est installé (inclus dans l'installation de Python depuis la version 3.4), il ne reste qu'à exécuter la ligne de commande suivante dans le terminal : ``python3 -m pip install Fiona``. Cette installation a été faite sur un système d’exploitation Linux Ubuntu.

Exécution
---------

- Convertir tous les fichiers SHP d'un dossier et ses sous-dossiers en Geopackages : 

::

    SHP2GPKG('C:/Users/Raphael_Bres/Desktop/SIG')

- Supprimer tous les fichiers SHP d'un dossier et ses sous-dossiers :

::

    shpKiller('C:/Users/Raphael_Bres/Desktop/SIG')

Fonctionnement
--------------

- Le script commence par explorer les fichiers du dossier indiqué en paramètre. 
- Si il trouve un dossier, il ré-exécute la fonction sur ce dossier. 
- Si il trouve un fichier, il vérifie que c’est un Shapefile et si c’est un Shapefile, il l’ouvre grâce à Fiona puis il modifie son schéma. Cette étape est très importante car Fiona reconnait beaucoup plus de types de géométrie que le Shapefile (14 pour Fiona contre 4 pour le Shapefile). Il nous faut donc nous adapter et surtout uniformiser l'ensemble des géométries d’un Shapefile. Afin de se débarrasser des points en 3D qui ne concernent pas les données que j’utilise, le préfixe 3D dans le type de géométrie est supprimé pour le futur fichier. Pour éviter les problèmes entre des entités simples et multiples (polygone et multi-polygone par exemple), le type de géométrie sera multiple pour toutes les entités d’une couche. 
- Ensuite, il créé un fichier GeoPackage avec les mêmes bases que le fichier Shapefile ouvert précédemment. 
- Il va ensuite rechercher le type de géométrie du Shapefile afin de créer dans le GeoPackage un objet correspondant à la bonne géométrie. 
- Une fois cette fonction terminée, la seconde fonction ``shpKiller`` permet de parcourir un dossier de la même manière que la première fonction mais cette fois, dès qu'un fichier composant du Shapefile est trouvé (.shp, .dbf, .shx, .prj, .qpj, .cpg), on le supprime.

En complément, voir aussi le script Python de création de SHP ou GPKG à partir d'une BDD PostGIS (https://github.com/PnX-SI/Ressources-techniques/tree/master/Python/create_GIS_files)


Utilisation de ogr2ogr
=======================
Dans le dossier `ogr2ogr_shp2gpkg` se trouve une méthode alternative reposant sur ogr2ogr pour convertir les fichiers

Un exemple d'utilisation du script se trouve dans le fichier main.py.sample

Prérequis : avoir ogr2ogr et python

