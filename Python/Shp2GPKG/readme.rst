# Script Python de conversion de fichiers Shapefiles en GeoPackages

Par Raphael Bres - Mars 2020

Mise à jour : 24 juin 2026

Le PNE a choisi de migrer ses fichiers SHP en GeoPackages (https://si.ecrins-parcnational.com/blog/2020-02-geojson-shapefile-geopackage.html).

Ce script permet d'automatiser la conversion des fichiers.

Afin de réaliser la migration du format Shapefile vers le format GeoPackage sans problèmes, j’ai réalisé ce script en Python qui, en prenant un chemin comme paramètre, transforme un fichier Shapefile en fichier GeoPackage avant de supprimer tous les fichiers Shapefile.

Le script a été initialement développé en 2020 et a été mis à jour en 2026 afin d'assurer sa compatibilité avec les versions récentes de Python et de Fiona.

## Installation

Cette fonction est récursive, ce qui veut dire que lorsqu’elle trouve un sous-dossier dans le dossier passé en paramètre, la fonction se réexécute toute seule dans le sous-dossier en question.

Ce programme utilise deux modules :

* `os` (inclus dans la bibliothèque standard Python) ;
* `Fiona` (https://github.com/Toblerity/Fiona).

Pour le module `os`, aucune installation supplémentaire n'est nécessaire.

Pour le module `Fiona`, si `pip` est installé (inclus par défaut dans Python depuis la version 3.4), il suffit d'exécuter la commande suivante :

::

```
python3 -m pip install Fiona
```

Ou pour mettre à jour Fiona vers la dernière version disponible :

::

```
python3 -m pip install --upgrade Fiona
```

Cette installation a été testée sous Linux Ubuntu mais le script est également compatible avec Windows et macOS sous réserve que Fiona soit correctement installé.

Versions recommandées :

* Python 3.9 ou supérieur ;
* Fiona 1.9 ou supérieur.

## Exécution

* Convertir tous les fichiers SHP d'un dossier et de ses sous-dossiers en GeoPackages :

::

```
SHP2GPKG('C:/Users/Raphael_Bres/Desktop/SIG')
```

* Supprimer tous les fichiers SHP d'un dossier et de ses sous-dossiers :

::

```
shpKiller('C:/Users/Raphael_Bres/Desktop/SIG')
```

Exemple complet :

::

```
from shp2gpkg import SHP2GPKG, shpKiller

repertoire = "C:/Users/Raphael_Bres/Desktop/SIG"

SHP2GPKG(repertoire)
shpKiller(repertoire)
```

## Fonctionnement

* Le script commence par explorer les fichiers du dossier indiqué en paramètre.
* S'il trouve un dossier, il ré-exécute la fonction sur ce dossier.
* S'il trouve un fichier, il vérifie qu’il s’agit d’un Shapefile. Si c’est le cas, il l’ouvre grâce à Fiona puis il modifie son schéma.

Cette étape est très importante car Fiona reconnaît davantage de types de géométrie que le format Shapefile (14 pour Fiona contre 4 pour le Shapefile). Il faut donc s’adapter et surtout uniformiser l’ensemble des géométries d’un Shapefile.

Afin de se débarrasser des géométries 3D qui ne concernent pas les données utilisées dans le cadre de ce projet, le préfixe `3D` du type de géométrie est supprimé pour le futur fichier.

Pour éviter les problèmes entre des entités simples et multiples (polygone et multipolygone par exemple), le type de géométrie est converti en type multiple pour toutes les entités d’une couche :

* Point → MultiPoint

* LineString → MultiLineString

* Polygon → MultiPolygon

* Ensuite, le script crée un fichier GeoPackage avec les mêmes caractéristiques que le fichier Shapefile ouvert précédemment.

* Il recherche ensuite le type de géométrie de chaque entité afin de créer dans le GeoPackage un objet correspondant à la bonne géométrie.

* Une fois cette fonction terminée, la seconde fonction `shpKiller` permet de parcourir un dossier de la même manière que la première fonction mais cette fois, dès qu'un fichier composant du Shapefile est trouvé (`.shp`, `.dbf`, `.shx`, `.prj`, `.qpj`, `.cpg`), il est supprimé.

## Limitations connues

* Les géométries 3D sont volontairement converties en géométries 2D.
* Le script ne réalise pas de validation topologique des géométries.
* Les tests de détection des géométries reposent sur la structure des coordonnées telle qu'elle est fournie par Fiona.
* Il est recommandé de conserver une sauvegarde des données avant d'exécuter `shpKiller`.

En complément, voir aussi le script Python de création de SHP ou GPKG à partir d'une BDD PostGIS :

https://github.com/PnX-SI/Ressources-techniques/tree/master/Python/create_GIS_files

# Changelog

## 24 juin 2026

Mise à jour de compatibilité avec les versions récentes de Fiona (1.9+) et de Python :

* conservation du comportement historique du script ;
* adaptation à l'évolution du modèle de données Fiona pour les objets `Feature` ;
* création explicite d'objets `feature` modifiables avant écriture dans le GeoPackage ;
* utilisation d'une copie du dictionnaire `meta` afin d'éviter les effets de bord ;
* ajout de la gestion des géométries nulles ;
* amélioration de la robustesse lors de l'écriture des entités ;
* mise à jour de la documentation et des prérequis logiciels ;
* aucun changement fonctionnel dans le processus de conversion.

# Utilisation de ogr2ogr

Dans le dossier `ogr2ogr_shp2gpkg` se trouve une méthode alternative reposant sur ogr2ogr pour convertir les fichiers SHP en GPKG.

Un exemple d'utilisation du script se trouve dans le fichier `main.py.sample`.

Prérequis :

* avoir GDAL/ogr2ogr installé sur sa machine ;
* avoir Python installé ;
* vérifier que la commande `ogr2ogr` est accessible depuis le terminal.