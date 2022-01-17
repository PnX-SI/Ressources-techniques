
# Intégrer un réseau dans une base de données Geotrek existante

La gestion des réseaux et leur mise à jour est un problème récurent dans Geotrek du fait de la segmentation dynamique. Nous étions confronté au problème suivant : dans notre base Geotrek nous avions un réseau de tronçons existants et suite à la mise en place d'un RLESI (Réseaux Locaux d’Espaces Sites et Itinéraires) sur une partie de notre territoire nous souhaitions substituer le réseau existant par celui défini par le RLESI.

Le RLESI couvrait une partie de notre territoire et sur cette zone nous avons des tronçons non présents dans le RLESI que nous souhaitons conserver. Du fait de la segmentation dynamique dans Geotrek, il ne nous était pas possible de supprimer les tronçons présent dans les deux réseaux une fois identifiés pour les remplacer par le nouveau référentiel. Nous devions modifier la géométrie de ces tronçons de façon à mettre à jour notre réseau sans "impacter" les données déjà présentes dans la base.

Le schéma ci dessous illuste les cas que nous avons du traiter:

<p align="center">
     <img src="img/comparaison_rlesi_troncons.png" height="500">
</p>

Ce travail a été méné par Idrissa DJEPA durant son stage puis un contrat au Parc national des Cévennes. Nous présentons ici les différentes étapes qui nous ont permis de réaliser la modification de notre réseau de tronçons dans note base Géotrek.

Cette documentation se découpe en trois parties :
 - [Préparation des données à intégrées](preparation_donnees.md)
 - [Analyse des réseaux en vu de leur fusion](agregation_reseaux.md)
 - [Import des données une fois traitées dans une base geotrek](import_donnees_geotrek.md)


---
**Outils nécessaires**

  * Qgis : visualisation et correction des données
  * Accès lecture/écriture à la base de données Geotrek
  * Possibilité de créer une nouvelle base Postgresql/Postgis

---
