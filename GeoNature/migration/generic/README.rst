Fonctions génériques d'import
=============================

Le script ``create_import_synthese.sql`` ajoute des fonctions permettant l'import de données dans la synthèse de GeoNature.

Elle permet de gérer les données de sources actives : 

* Insertion des données non présentes dans la synthèse
* Mise à jour des données qui ont été modifiées depuis la dernière synchro
* Suppression des données qui ne sont plus présentes dans la source

Structure des données
---------------------

Tables :

* ``t_synchronisation_configs`` : Table de définition des synchros
* ``t_synchronisation_logs`` : Table de log des synchronisations réalisées avec succès ou pas

Fonctions :

* ``import_synthese.fct_sync_synthese(code_sync)`` : Fonction qui réalise la synchronisation

Principes
---------

* Les champs ayant le même nom dans la table source et la table synthèse sont mappés et pris en compte, les autres champs sont exclus
* L'identification des données se fait à partir du champ ``entity_source_pk_value`` et de ``id_source``. Ces champs doivent donc être **présents, uniques et avoir une pérénité au niveau de la source**

Import des observateurs
-----------------------

Si votre source a les observateurs en lien avec UsersHub il est possible de spécifier à l'import de peupler ``cor_observer_synthese``

Pour cela il faut que :

* la source est un champ ``id_observers`` de type array
* mettre à TRUE le paramètre ``with_observers``

A faire
-------

* Tester la validité de la source : 

  * valeur non null pour les champs obligatoires
  * type de données


Exemple 
-------

Pour SICEN : 

* Suivre les étapes de 0 à 1 des scripts d'import SICEN
* Création d'une table ou d'une vue contenant les données ``import_synthese.obs_occ_data`` (Dans l'exemple c'est une table qui est créée pour des questions de performances). Voir le script ``exemple_sicen.sql``
* Enregistrement de la synchronisation : 

::

    INSERT INTO import_synthese.t_synchronisation_configs (code_name, table_name, with_observers)
        VALUES ('obs_occ', 'import_synthese.obs_occ_data', TRUE);


* Réalisation synchronisation : 

::

    SELECT import_synthese.fct_sync_synthese('obs_occ');

Cette synchro est à lancer automatiquement en cron et dans cet exemple il faut également remettre la table à jour.
