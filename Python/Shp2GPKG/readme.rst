Script python de conversion de fichiers shapefiles en GeoPackages
-----------------------------------------------------------------

Le PNE a choisi de migrer ses fichiers SHP en GeoPackages (https://si.ecrins-parcnational.com/blog/2020-02-geojson-shapefile-geopackage.html).
Ce script permet d'automatiser la conversion des fichiers. 

Afin de réaliser la transition entre le format Shapefile et le format GéoPackage sans problèmes, j’ai réalisé un programme en Python qui, 
en prenant un chemin comme paramètre, transforme un fichier Shapefile en fichier GéoPackage avant de supprimer tous les fichiers 
nécessaires au Shapefile. Cette fonction est récursive, ce qui veut dire que lorsqu’elle trouve un sous dossier dans le dossier passé 
en paramètre, la fonction se réexécute toute seule dans le sous dossier en question. Ce programme utilise deux modules en plus de Python 3 
qui sont os et Fiona. Pour le module os, il est normalement inclus dans l’installation de Python. Pour le module Fiona, 
si pip est installé (c’est inclus dans l’installation de Python depuis la version 3.4), il ne reste qu’à lancer la ligne de commande 
suivante dans le terminal : ``python3 -m pip install Fiona``. Cette installation a été faite sur un système d’exploitation Linux Ubuntu.

Pour rapidement expliquer le code, on commence par explorer les fichiers du dossier en paramètre. Si on trouve un dossier, on réexécute 
la fonction sur ce dossier. Si on trouve un fichier, on vérifie que c’est un Shapefile et si c’est un Shapefile, on l’ouvre grâce à Fiona 
puis on modifie son schéma. Cette étape est très importante car Fiona reconnait beaucoup plus de types de géométrie que le Shapefile 
(14 pour Fiona contre 4 pour le Shapefile). Il nous faut donc nous adapter et surtout uniformiser l’ensemble des géométries d’un 
Shapefile. Afin de se débarrasser des points en 3D qui ne concernent pas les données que j’utilise, le préfixe 3D dans le type de 
géométrie est supprimé pour le futur fichier. Pour éviter les problèmes entre des entités simples et multiples (polygone et multi polygone 
par exemple), le type de géométrie sera multiple pour toutes les entités d’une couche. Ensuite, on crée un fichier GéoPackage avec les 
mêmes bases que le fichier Shapefile ouvert précédemment. On va ensuite rechercher le type de géométrie du Shapefile afin de créer dans 
le GéoPackage un objet correspondant à la bonne géométrie. Une fois cette fonction terminée, on lance une seconde fonction qui va 
parcourir un dossier de la même manière que la première fonction mais cette fois, dès qu’un fichier composant du Shapefile est trouvé 
(.shp, .dbf, .shx, .prj, .qpj, .cpg), on le supprime.

En complément, voir aussi le script Python de création de SHP ou GPKG à partir d'une BDD PostGIS (https://github.com/PnX-SI/Ressources-techniques/tree/master/Python/create_GIS_files)
