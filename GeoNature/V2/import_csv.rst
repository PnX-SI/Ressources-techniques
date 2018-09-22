Exemple d'import d'une source CSV
=================================


**Chargement du fichier CSV dans la base de données**

La fonction ``gn_imports.load_csv_file('/path/to/file.csv', 'targetschema.targettable')``
permet d'importer un fichier CSV directement dans la base de données GeoNature2.

.. code:: sql

    SELECT gn_imports.load_csv_file('/home/users/imports/Observations.csv', 'gn_imports.testimport');

:notes:

    * Attention : si la table existe, elle est supprimée et recréée à partir du CSV fourni.
    * La fonction créé la table et sa structure dans le schéma et la table fournis en paramètre.
    * Le contenu du fichier CSV est chargé dans la table (initialement toutes les colonnes sont de type ``text``).
    * La function tente ensuite d'identifier et de modifier le type de chacune des colonnes à partir du contenu.
    * Seuls les types ``integer``, ``real``, et ``date`` sont actuellement proposés. 

Si vous devez modifier manuellement le type d'une colonne, vous pouvez vous inspirer du code suivant :

.. code:: sql

    ALTER TABLE monschema.matable ALTER COLUMN macolonne TYPE montype USING macolonne::montype;


:notes:

    * Le fichier CSV doit être présent localement sur le serveur hébergeant la base de données.
    * Il fichier doit être encodé en UTF-8 et la première ligne doit comporter le nom des champs.
    * Le séparateur de champs doit être le point-virgule.
    * La fonction utilise la fonction ``COPY`` capable de lire le système de fichier du serveur. Pour des raisons de sécurité, cette fonction ``COPY`` n'est accessible qu'aux superutilisateurs. Vous devez donc disposer d'un accès superutilisateur pour utiliser cette function d'import.

En l'état vos données sont importées et stockées dans la base GeoNature. Cependant GeoNature ne connait pas ces données. Pour qu'elles soient utilisables, au moins en consultation, vous devez fournir à l'application GeoNature un certain nombre d'informations concernant ces données et à minima les importer dans la synthèse. Vous pouvez également les importer dans un autre module, comme "Occtax" (non abordé dans cet exemple).

**Création des metadonnées obligatoires**

Il est nécessaire de rattacher les données importées à un jeu de données qui doit appartenir à un cadre d'acquisition. Si ceux-ci n'ont pas encore été créés dans la base, vous devez le faire dans ``gn_meta.t_acquisition_frameworks`` pour le cadre d'acquisition et dans ``gn_meta.t_datasets`` pour le jeu de données.
Vous pouvez pour cela utiliser les formulaires disponibles ici : http://localhost/geonature/admin

Il est également nécessaire, pour la synthese, de lui indiquer où sont stockées les données qu'elle contient et comment y accèder. Vous devez pour cela disposer d'une source de données dans ``gn_synthese.t_sources`` correspondant aux données à importer.
Pour l'exemple nous allons créer une source de données avec la commande sql suivante

.. code:: sql

    INSERT INTO gn_synthese.t_sources(name_source, desc_source, entity_source_pk_field, groupe_source, active) 
    VALUES('test import', 'un test d''import pour voir', 'gn_imports.testimport.gid', 'IMPORT', true) returning id_source;
    
    
Notez bien le ``id_source`` retourné, nous devrons l'utiliser lors de l'import des données dans la synthèse.


**Analyse du contenu**

* Observateur(s)
* format date
* ...
* TODO

**Mapping des champs du fichier source avec la synthese**

Le schéma ``gn_imports`` comporte trois tables permettant de préparer le mapping des champs entre la table importée (source) et une table de destination (target).

* ``gn_imports.matching_tables`` permet de déclarer la table source et la table de destination. Noter le ``id_matching_table`` généré par la séquence lors de l'insertion d'un nouveau "matching" dans cette table.
* ``gn_imports.matching_fields`` permet de faire le matching entre les champs de la table source et de la table de destination. Vous devez indiquer le type de chacun des champs de la table de destination ainsi que le ``id_matching_table``.
* ``gn_imports.matching_geoms`` permet de préparer la création du geom dans la table de destination à partir du ou des champs constituant le geom fourni dans la table source : champs contenant les ``x`` et ``y`` pour un format "xy" ou le champ comportant le wkt pouor le format wkt.

En attendant la création d'une interface permettant de faciliter l'import, vous devez remplir ces tables manuellement.
Cependant, la fonction ``gn_imports.fct_generate_mapping('table_source', 'table_cible', forcedelete)`` permet de pregénérer un mapping. Si le mapping source/cible existe, la fonction ne fait rien et un message d'erreur est levé. Si le mapping n'existe pas ou si le paramètre ``forcedelete`` (boolean default = false) est à ``true``, la fonction crée le mapping en remplissant la table ``gn_imports.matching_tables`` et la table``gn_imports.matching_fields`` avec une ligne par champ de la table cible. Il ne vous reste plus qu'à manuellement supprimer ou remplacer les valeurs 'replace me' dans le champs ``source_field`` ou les valeurs par défaut proposées par la fonction.

.. code:: sql

    SELECT gn_imports.fct_generate_matching('gn_imports.testimport', 'gn_synthese.synthese');
    ou
    SELECT gn_imports.fct_generate_matching('gn_imports.testimport', 'gn_synthese.synthese', true);

:notes:

    * Au moins un des 2 champs ``source_field`` ou ``source_default_value`` doit être renseigné.
    * Si le champ ``source_field`` est renseigné, le champ ``source_default_value`` est ignoré.


Une fois que le mapping est renseigné, vous pouvez lancer la fonction ``gn_imports.fct_generate_import_query('table_source', 'table_cible');`` qui va générer la requête ``INSERT INTO``.
Attention, pg_admin va tronquer le résultat. Pour obtenir l'ensemble de la requête utiliser le bouton d'export du résultat dans un fichier ou executé la requête avec psql.

Exemple

.. code:: sql

    SELECT gn_imports.fct_generate_import_query('gn_imports.testimport', 'gn_synthese.synthese');

:notes:

    Il est possible d'utiliser ce mécanisme générique pour insérer des données de n'importe quelle table vers n'importe quelle autre, à partir du moment où il est possible d'établir un mapping cohérent entre les champs et notamment que les types puissent correspondre ou soient "transtypables".
