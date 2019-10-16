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
    ), owners AS (
        SELECT rolname, dependant_view
        FROM pg_shdepend d 
        JOIN t 
        ON d.objid = t.dependant_view::regclass
        JOIN pg_roles r on r.oid = d.refobjid
        WHERE deptype='o'
    ), privileges AS (
        SELECT 'GRANT ' || string_agg(privilege_type, ', ') || ' ON TABLE ' || ns.oid::text || ' TO ' || r2.rolname || '; ' as sql_privileges
        FROM (
            SELECT oid::regclass,
               (aclexplode(relacl)).grantee,
               (aclexplode(relacl)).privilege_type
            FROM pg_class
        ) as ns
        JOIN pg_roles r2 ON ns.grantee = r2.oid
        JOIN t on t.dependant_view::regclass = ns.oid
        GROUP BY ns.oid, r2.rolname, i
    )
    SELECT sql 
    FROM (
        SELECT 
            'CREATE ' || 
            CASE WHEN NOT m.schemaname IS NULL THEN 'MATERIALIZED' ELSE '' END
            || ' VIEW ' || t.dependant_view || E' AS \n' || pg_get_viewdef(t.dependant_view, true) || ';' ||
            '\n ALTER TABLE ' || t.dependant_view || ' OWNER TO '|| rolname || ';' as sql, i
        FROM t
        JOIN owners o 
        ON o.dependant_view = t.dependant_view
        LEFT OUTER JOIN pg_matviews m
        ON schemaname || '.' || matviewname = t.dependant_view::text
        UNION
        SELECT sql_privileges, 10000 as i
        FROM privileges
        ORDER BY i ASC
    )a;


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

