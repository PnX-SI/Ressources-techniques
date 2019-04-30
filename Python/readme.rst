Script python de création de shapefiles/GeoPackages
---------------------------------------------------

Ce script permet de se connecter à une base de données PostgreSQL et de générer des fichiers shapefiles et GeoPackages.

Il utilise la librairie Fiona https://fiona.readthedocs.io/en/latest/manual.html#the-fiona-user-manual

Créer un environnement virtuel python (``sudo apt-get install sudo apt-get install -y python3-virtualenv virtualenv`` si virtualenv n'est pas installé), puis installer les librairies necessaire au bon fonctionnement du scrit:

::

  virtualenv -p python3 venv
  source venv/bin/activate
  pip install -r requirements.txt
  

Editer le fichier ``config.py`` et renseigner 
- vos identifiants de connexion de BDD
- un requête SQL qui à minima contenir un champ de type geometry et les colonnes que l'on souhaite exporter
- le schéma du fichier en sortie (colonnes et leur types) en s'inspirant de l'exemple fournit. Voir https://fiona.readthedocs.io/en/latest/manual.html#field-types
- le format de fichier en sortie (Shapefile ou GeoPackage)
- le SRID
- l'emplacement du fichier en sortie

Lancer le script:

::

    python main.py