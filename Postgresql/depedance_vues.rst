# Génération automatique de scripts sql de suppression/creation des vues dépendantes d'un objet



```
--Création du script de suppression des vues dépendantes

WITH RECURSIVE t(orig_view, dependant_view, i) AS (
    SELECT DISTINCT 'monschema.mavue' as orig_view, r.ev_class::regclass as views, 1 as i
    FROM pg_depend d 
    JOIN pg_rewrite r ON r.oid = d.objid 
    WHERE refobjid = 'monschema.mavue'::regclass
        AND NOT r.ev_class = 'monschema.mavue'::regclass
        AND classid = 'pg_rewrite'::regclass 
    UNION ALL
    SELECT distinct t.dependant_view::text as orig_view, r.ev_class::regclass as views, t.i +1 as i
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
```

```
--Création du script de recréation des vues dépendantes

WITH RECURSIVE t(orig_view, dependant_view, i) AS (
    SELECT DISTINCT 'monschema.mavue' as orig_view, r.ev_class::regclass as views, 1 as i
    FROM pg_depend d JOIN pg_rewrite r ON r.oid = d.objid 
    WHERE refobjid = 'monschema.mavue'::regclass
        AND NOT r.ev_class = 'monschema.mavue'::regclass
        AND classid = 'pg_rewrite'::regclass 
    UNION ALL
    SELECT distinct t.dependant_view::text as orig_view, r.ev_class::regclass as views, t.i +1 as i
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
```

Utilisation avec psql de façon à générer les scripts

```
\t
\o /tmp/drop.sql
DELETE QUERY;

\o /tmp/create.sql
RECREATE QUERY;
```