Génération automatique de scripts sql de suppression/creation des vues dépendantes d'un objet
=====

Lorsque l'on veut rajouter un champ à une vue ou modifier le type de données d'une colonne, postgresql bloque les modifications (a raison) s'il y a des objets dépendants.

Si vous en avez mare d'avoir le message d'erreur suivant et de faire de copier coller du code sql des vues dépendantes

.. code-block:: sql

    ERROR: cannot drop view XXX because other objects depend on it
    État SQL :2BP01
    Détail : ....
    Astuce : Use DROP ... CASCADE to drop the dependent objects too.


Fonctions génériques
--------------------
Trouvé sur stackoverflow : https://stackoverflow.com/questions/3243863/problem-with-postgres-alter-table/49000321 

Création table de stockage des dépendances

.. code-block:: sql

    CREATE TABLE gn_commons.deps_saved_ddl
    (
      deps_id serial NOT NULL,
      deps_view_schema character varying(255),
      deps_view_name character varying(255),
      deps_ddl_to_run text,
      CONSTRAINT deps_saved_ddl_pkey PRIMARY KEY (deps_id)
    );


Fonction qui stocke et supprime les dépendances

.. code-block:: sql

    CREATE OR REPLACE FUNCTION gn_commons.deps_save_and_drop_dependencies(
        p_view_schema character varying,
        p_view_name character varying)
      RETURNS void AS
    $BODY$
    declare
      v_curr record;
    begin
    for v_curr in 
    (
      select obj_schema, obj_name, obj_type from
      (
      with recursive recursive_deps(obj_schema, obj_name, obj_type, depth) as 
      (
        select p_view_schema, p_view_name, null::varchar, 0
        union
        select dep_schema::varchar, dep_name::varchar, dep_type::varchar, recursive_deps.depth + 1 from 
        (
          select ref_nsp.nspname ref_schema, ref_cl.relname ref_name, 
          rwr_cl.relkind dep_type,
          rwr_nsp.nspname dep_schema,
          rwr_cl.relname dep_name
          from pg_depend dep
          join pg_class ref_cl on dep.refobjid = ref_cl.oid
          join pg_namespace ref_nsp on ref_cl.relnamespace = ref_nsp.oid
          join pg_rewrite rwr on dep.objid = rwr.oid
          join pg_class rwr_cl on rwr.ev_class = rwr_cl.oid
          join pg_namespace rwr_nsp on rwr_cl.relnamespace = rwr_nsp.oid
          where dep.deptype = 'n'
          and dep.classid = 'pg_rewrite'::regclass
        ) deps
        join recursive_deps on deps.ref_schema = recursive_deps.obj_schema and deps.ref_name = recursive_deps.obj_name
        where (deps.ref_schema != deps.dep_schema or deps.ref_name != deps.dep_name)
      )
      select obj_schema, obj_name, obj_type, depth
      from recursive_deps 
      where depth > 0
      ) t
      group by obj_schema, obj_name, obj_type
      order by max(depth) desc
    ) loop

      insert into gn_commons.deps_saved_ddl(deps_view_schema, deps_view_name, deps_ddl_to_run)
      select p_view_schema, p_view_name, 'COMMENT ON ' ||
      case
      when c.relkind = 'v' then 'VIEW'
      when c.relkind = 'm' then 'MATERIALIZED VIEW'
      else ''
      end
      || ' ' || n.nspname || '.' || c.relname || ' IS ''' || replace(d.description, '''', '''''') || ''';'
      from pg_class c
      join pg_namespace n on n.oid = c.relnamespace
      join pg_description d on d.objoid = c.oid and d.objsubid = 0
      where n.nspname = v_curr.obj_schema and c.relname = v_curr.obj_name and d.description is not null;

      insert into gn_commons.deps_saved_ddl(deps_view_schema, deps_view_name, deps_ddl_to_run)
      select p_view_schema, p_view_name, 'COMMENT ON COLUMN ' || n.nspname || '.' || c.relname || '.' || a.attname || ' IS ''' || replace(d.description, '''', '''''') || ''';'
      from pg_class c
      join pg_attribute a on c.oid = a.attrelid
      join pg_namespace n on n.oid = c.relnamespace
      join pg_description d on d.objoid = c.oid and d.objsubid = a.attnum
      where n.nspname = v_curr.obj_schema and c.relname = v_curr.obj_name and d.description is not null;

      insert into gn_commons.deps_saved_ddl(deps_view_schema, deps_view_name, deps_ddl_to_run)
      select p_view_schema, p_view_name, 'GRANT ' || privilege_type || ' ON ' || table_schema || '.' || table_name || ' TO ' || grantee
      from information_schema.role_table_grants
      where table_schema = v_curr.obj_schema and table_name = v_curr.obj_name;

      if v_curr.obj_type = 'v' then
        insert into gn_commons.deps_saved_ddl(deps_view_schema, deps_view_name, deps_ddl_to_run)
        select p_view_schema, p_view_name, 'CREATE VIEW ' || v_curr.obj_schema || '.' || v_curr.obj_name || ' AS ' || view_definition
        from information_schema.views
        where table_schema = v_curr.obj_schema and table_name = v_curr.obj_name;
      elsif v_curr.obj_type = 'm' then
        insert into gn_commons.deps_saved_ddl(deps_view_schema, deps_view_name, deps_ddl_to_run)
        select p_view_schema, p_view_name, 'CREATE MATERIALIZED VIEW ' || v_curr.obj_schema || '.' || v_curr.obj_name || ' AS ' || definition
        from pg_matviews
        where schemaname = v_curr.obj_schema and matviewname = v_curr.obj_name;
      end if;

      execute 'DROP ' ||
      case 
        when v_curr.obj_type = 'v' then 'VIEW'
        when v_curr.obj_type = 'm' then 'MATERIALIZED VIEW'
      end
      || ' ' || v_curr.obj_schema || '.' || v_curr.obj_name;

    end loop;
    end;
    $BODY$
      LANGUAGE plpgsql VOLATILE
      COST 100;


Fonction de restauration des dépendances

.. code-block:: sql

    CREATE OR REPLACE FUNCTION gn_commons.deps_restore_dependencies(
        p_view_schema character varying,
        p_view_name character varying)
      RETURNS void AS
    $BODY$
    declare
      v_curr record;
    begin
    for v_curr in 
    (
      select deps_ddl_to_run 
      from gn_commons.deps_saved_ddl
      where deps_view_schema = p_view_schema and deps_view_name = p_view_name
      order by deps_id desc
    ) loop
      execute v_curr.deps_ddl_to_run;
    end loop;
    delete from gn_commons.deps_saved_ddl
    where deps_view_schema = p_view_schema and deps_view_name = p_view_name;
    end;
    $BODY$
      LANGUAGE plpgsql VOLATILE
      COST 100;


Exemple d'utilisation

.. code-block:: sql

    SELECT gn_commons.deps_save_and_drop_dependencies('taxonomie', 'taxref');

    ALTER TABLE taxonomie.taxref ALTER COLUMN  nom_valide TYPE character varying(500) USING nom_valide::character varying(500);

    SELECT gn_commons.deps_restore_dependencies('taxonomie', 'taxref');
    

Ancienne version maison que l'on peut adapter
--------------------------------------------

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

