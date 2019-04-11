Génération automatique de scripts sql de suppression/creation des vues dépendantes d'un objet
=====

Lorsque l'on veut rajouter un champ à une vue ou modifier le type de données d'une colonne, postgresql bloque les modifications (a raison) s'il y a des objets dépendants.

Si vous en avez mare d'avoir le message d'erreur suivant et de faire de copier coller du code sql des vues dépendantes

.. code-block:: sql

    ERROR: cannot drop view XXX because other objects depend on it
    État SQL :2BP01
    Détail : ....
    Astuce : Use DROP ... CASCADE to drop the dependent objects too.



Ci dessous deux requetes qui permettent de générer du sql de suppression des vues dépendantes et de recréation de ces vues de façon récursive.

.. code-block:: sql

    --Création du script de suppression des vues dépendantes

    WITH RECURSIVE t(orig_view, dependant_view, i) AS (
        SELECT DISTINCT 'monschema.mavue' as orig_view, r.ev_class::regclass as views, 1 as i
        FROM pg_depend d 
        JOIN pg_rewrite r ON r.oid = d.objid 
        WHERE refobjid = 'monschema.mavue'::regclass
            AND NOT r.ev_class = 'monschema.mavue'::regclass
            AND classid = 'pg_rewrite'::regclass 
        UNION ALL
        SELECT DISTINCT t.dependant_view::text as orig_view, r.ev_class::regclass as views, t.i +1 as i
        FROM pg_depend d
        JOIN pg_rewrite r ON r.oid = d.objid 
        JOIN t ON refobjid = t.dependant_view::regclass
        WHERE refclassid = 'pg_class'::regclass
            AND NOT r.ev_class = t.dependant_view::regclass
            AND classid = 'pg_rewrite'::regclass 
    )
    SELECT 'DROP ' || 
        CASE WHEN NOT m.schemaname IS NULL THEN 'MATERIALIZED ' ELSE '' END
        || ' VIEW ' || dependant_view || ';'
    FROM t
    LEFT OUTER JOIN pg_matviews m
    ON schemaname || '.' || matviewname = dependant_view::text
    ORDER BY i DESC;



.. code-block:: sql

    --Création du script de recréation des vues dépendantes

    WITH RECURSIVE t(orig_view, dependant_view, i) AS (
        SELECT DISTINCT 'monschema.mavue' as orig_view, r.ev_class::regclass as views, 1 as i
        FROM pg_depend d JOIN pg_rewrite r ON r.oid = d.objid 
        WHERE refobjid = 'monschema.mavue'::regclass
            AND NOT r.ev_class = 'monschema.mavue'::regclass
            AND classid = 'pg_rewrite'::regclass 
        UNION ALL
        SELECT DISTINCT t.dependant_view::text as orig_view, r.ev_class::regclass as views, t.i +1 as i
        FROM pg_depend d
        JOIN pg_rewrite r ON r.oid = d.objid 
        JOIN t ON refobjid = t.dependant_view::regclass
        WHERE refclassid = 'pg_class'::regclass
            AND NOT r.ev_class = t.dependant_view::regclass
            AND classid = 'pg_rewrite'::regclass 
    )
    SELECT 
        'CREATE ' || 
        CASE WHEN NOT m.schemaname IS NULL THEN 'MATERIALIZED' ELSE '' END
        || ' VIEW ' || dependant_view || E' AS \n' || pg_get_viewdef(dependant_view, true) || ';'
    FROM t
    LEFT OUTER JOIN pg_matviews m
    ON schemaname || '.' || matviewname = dependant_view::text
    ORDER BY i ASC;

Automatisation
==============
Utilisation avec psql de façon à générer les scripts

.. code-block:: sh

    \t
    \o /tmp/drop.sql
    DELETE QUERY;

    \o /tmp/create.sql
    RECREATE QUERY;
    
Pour aller plus loin il serait possible de créer des fonctions ou de passer le nom de la vue en paramètre psql


.. code-block:: sh
    
    psql -v mavar="'Hello World'"
    
    select :mavar;

