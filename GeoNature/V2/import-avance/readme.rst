IMPORT NIVEAU 2
===============

Description
-----------

L'exercice consiste à importer le fichier ``observations.csv`` dans GeoNature V2.

1 - On charge le fichier CSV dans une table de la base de données.

2 - On prépare la table importée (FK et typage des champs si besoin).

3 - On créé les métadonnées pour que GeoNature sache identifier les nouvelles données.

4 - On mappe les champs de la table d'import avec ceux de la synthèse. 

    Pour cela on utilise une fonction dédiée qui nous prépare le travail. Il ne reste plus qu'à finaliser le mapping (la fonction ne peut pas tout deviner).

5 - On crée la requête d'import. 

    Pour cela on utilise une fonction dédiée qui nous prépare le travail. On adapte la requête produite par la fonction.
    
6 - On importe les données en synthèse.

7 - On gère les nouveaux taxons vis à vis la saisie.

8 - On archive la table où on veut.

Exercice disponible sur https://geonature.readthedocs.io/fr/develop/import-level-2.html
