
CREATE TABLE gn_imports.gn_imports_log (
    id_log SERIAL PRIMARY KEY,
    table_name varchar(500),
    success boolean,
    error_msg text,
    start_time timestamp,
    end_time timestamp,
    nb_insert int DEFAULT(0), 
    nb_update int DEFAULT(0), 
    nb_delete int DEFAULT(0)
);
-- Function: gn_imports.import_static_source(character varying, integer, integer)

-- DROP FUNCTION gn_imports.import_static_source(character varying, integer, integer);

CREATE OR REPLACE FUNCTION gn_imports.import_static_source(
    tablename character varying,
    idsource integer,
    iddataset integer)
  RETURNS boolean AS
$BODY$
  DECLARE
    insert_cmd text;
    insert_columns text;
    select_cmd text;
    select_columns text;
    update_columns text;
    update_cmd text;

    v_error_stack text;
    start_time timestamp;
  BEGIN
   -- Création de la requete d'insertion
    insert_cmd := 'INSERT INTO gn_synthese.synthese ( id_source, ';
    select_cmd := 'SELECT ' || idsource || ' as id_source, ';
    update_cmd := '';
    start_time := (SELECT clock_timestamp());

    RAISE NOTICE 'START %', start_time;
    --Test si id_dataset est spécifié
    IF (
        SELECT true
        FROM   pg_attribute
        WHERE  attrelid = tablename::regclass
            AND    attname::text = 'id_dataset'
    ) IS NULL THEN
        insert_cmd := insert_cmd || 'id_dataset, ';
        select_cmd := select_cmd || iddataset || ' AS id_dataset, ';
        update_cmd := 'id_dataset = ' || iddataset || ', ';
    END IF;

    WITH import_col AS (
        SELECT attname::text as column_name
        FROM   pg_attribute
        WHERE  attrelid = tablename::regclass
            AND    attnum > 0
            AND    NOT attisdropped
    ), synt_col AS (
        SELECT column_name, column_default, CASE WHEN data_type = 'USER-DEFINED' THEN NULL ELSE data_type END as data_type
        FROM information_schema.columns  
        WHERE table_schema || '.' || table_name = 'gn_synthese.synthese' AND NOT column_name = 'id_source'
    )
    SELECT 
        string_agg(s.column_name, ',')  as insert_columns,
        string_agg(
            CASE 
                WHEN NOT column_default IS NULL THEN 'COALESCE(d.' || i.column_name  || COALESCE('::' || data_type, '') || ', ' || column_default || ') as ' || i.column_name
            ELSE 'd.' || i.column_name || COALESCE('::' || data_type, '')
            END, ',' 
        ) as select_columns ,
        string_agg(
            s.column_name || '=' || CASE 
                WHEN NOT column_default IS NULL THEN 'COALESCE(d.' || i.column_name  || COALESCE('::' || data_type, '') || ', ' || column_default || ') '
            ELSE 'd.' || i.column_name || COALESCE('::' || data_type, '')
            END
        , ',') 
    INTO insert_columns, select_columns, update_columns
    FROM synt_col s
    JOIN import_col i
    ON i.column_name = s.column_name;
    

    ALTER TABLE gn_synthese.synthese DISABLE TRIGGER ALL;
    
    RAISE NOTICE 'Import data : %', clock_timestamp();
    DROP TABLE IF EXISTS tmp_process_import;
    CREATE TEMP TABLE tmp_process_import (
        id_synthese int, 
        entity_source_pk_value varchar, 
        cd_nom int,
        action char(1)
    );

    EXECUTE 'WITH inserted_rows as (' || 
            insert_cmd || insert_columns || ') ' || select_cmd || select_columns  || 
            ' FROM ' || tablename ||' d 
            LEFT OUTER JOIN gn_synthese.synthese s
            ON d.entity_source_pk_value::varchar = s.entity_source_pk_value AND s.id_source = ' || idsource || '
            WHERE s.id_synthese IS NULL 
            RETURNING id_synthese, entity_source_pk_value::varchar, cd_nom
        )
        INSERT INTO tmp_process_import
        SELECT id_synthese, entity_source_pk_value, cd_nom, ''I'' as action
        FROM inserted_rows'
    ;
    
    EXECUTE 'WITH updated_rows as (
            UPDATE gn_synthese.synthese s SET '  ||  update_cmd || update_columns ||
            ' FROM ' || tablename || ' d
            LEFT OUTER JOIN tmp_process_import t
            ON t.entity_source_pk_value = d.entity_source_pk_value::varchar
            WHERE 
                t.entity_source_pk_value IS NULL
                AND d.id_source = ' || idsource || '
                AND d.entity_source_pk_value::varchar = s.entity_source_pk_value
            RETURNING s.id_synthese, s.entity_source_pk_value, s.cd_nom
        )
        INSERT INTO tmp_process_import
        SELECT id_synthese, entity_source_pk_value, cd_nom, ''U'' as action
        FROM updated_rows'
    ;
    
    RAISE NOTICE 'Update cor_area_synthese : %', clock_timestamp();
    
    DELETE FROM gn_synthese.cor_area_synthese
    WHERE id_synthese IN (SELECT id_synthese FROM tmp_process_import);
    
    WITH not_in_corarea AS (
        SELECT s.id_synthese, s.the_geom_local 
        FROM gn_synthese.synthese  s
        JOIN tmp_process_import c
        ON c.id_synthese = s.id_synthese
        WHERE c.action IN ('I', 'U')
    )
    INSERT INTO gn_synthese.cor_area_synthese
    SELECT DISTINCT id_synthese, id_area
    FROM  not_in_corarea s
    JOIN ref_geo.l_areas l
    ON st_intersects(s.the_geom_local, l.geom);

    --Test si ids_observateur est spécifié
    IF (
        SELECT true
        FROM   pg_attribute
        WHERE  attrelid = tablename::regclass
            AND    attname::text = 'ids_observateur'
    ) IS TRUE THEN
        RAISE NOTICE 'Import des observateurs : %', clock_timestamp();
        -- Import des observateurs

        ALTER TABLE gn_synthese.cor_observer_synthese DISABLE TRIGGER ALL;
        
        RAISE NOTICE '	Clean observateurs : %', clock_timestamp();
        DELETE FROM gn_synthese.cor_observer_synthese
        USING tmp_process_import 
	WHERE cor_observer_synthese.id_synthese = tmp_process_import.id_synthese ;
        
        RAISE NOTICE '	INSERT observateurs : %', clock_timestamp();
        EXECUTE FORMAT (
            'WITH obs AS (
                SELECT id_synthese,  unnest(ids_observateur)::int as id_role
                FROM %s d
                JOIN tmp_process_import c
                on d.entity_source_pk_value = d.entity_source_pk_value
                WHERE c.action IN (''I'', ''U'')
            )
            INSERT INTO gn_synthese.cor_observer_synthese (id_synthese, id_role)
            SELECT DISTINCT id_synthese, id_role
            FROM obs
            JOIN utilisateurs.t_roles 
            USING(id_role)
            ',
            tablename
          );
        ALTER TABLE gn_synthese.cor_observer_synthese ENABLE TRIGGER ALL;
    END IF;

    RAISE NOTICE 'Update taxons_synthese_autocomplete A FINALISER manque la suppression : %', clock_timestamp();
        WITH new_cd_nom AS (
        SELECT DISTINCT c.cd_nom
        FROM gn_synthese.taxons_synthese_autocomplete s
        LEFT OUTER JOIN tmp_process_import c
        ON c.cd_nom = s.cd_nom
        WHERE s.cd_nom IS NULL AND c.action IN ('I', 'U')
   )
    INSERT INTO gn_synthese.taxons_synthese_autocomplete
    SELECT t.cd_nom,
                  t.cd_ref,
              concat(t.lb_nom, ' = <i>', t.nom_valide, '</i>', ' - [', t.id_rang, ' - ', t.cd_nom , ']') AS search_name,
              t.nom_valide,
              t.lb_nom,
              t.regne,
              t.group2_inpn
    FROM taxonomie.taxref t  WHERE cd_nom IN (SELECT DISTINCT cd_nom FROM new_cd_nom)
    UNION
    SELECT t.cd_nom,
    t.cd_ref,
    concat(t.nom_vern, ' =  <i> ', t.nom_valide, '</i>', ' - [', t.id_rang, ' - ', t.cd_nom , ']' ) AS search_name,
    t.nom_valide,
    t.lb_nom,
    t.regne,
    t.group2_inpn
    FROM taxonomie.taxref t  WHERE t.nom_vern IS NOT NULL AND cd_nom IN (SELECT DISTINCT cd_nom FROM new_cd_nom);

    ALTER TABLE gn_synthese.synthese ENABLE TRIGGER ALL;

    INSERT INTO gn_imports.gn_imports_log (
    table_name, success, error_msg, start_time, end_time, nb_insert, nb_update, nb_delete
    )
    SELECT 
        tablename, true, NULL, start_time, clock_timestamp(), 
        count(*) FILTER (WHERE action='I') as nb_insert,
        count(*) FILTER (WHERE action='U') as nb_update,
        count(*) FILTER (WHERE action='D') as nb_delete
    FROM tmp_process_import;
    
    RAISE NOTICE 'END : %', clock_timestamp();
    RETURN true;
    
EXCEPTION
   WHEN OTHERS THEN
    RAISE NOTICE 'Error during import process .... ';
    GET STACKED DIAGNOSTICS v_error_stack = PG_EXCEPTION_CONTEXT;
    RAISE WARNING 'The stack trace of the error is: "%"', v_error_stack;
    
    ALTER TABLE gn_synthese.synthese ENABLE TRIGGER ALL;
    ALTER TABLE gn_synthese.cor_observer_synthese ENABLE TRIGGER ALL;

    INSERT INTO gn_imports.gn_imports_log (table_name, success, error_msg, start_time, end_time)
    VALUES (tablename, false, v_error_stack, start_time, clock_timestamp());
    
    RETURN false;
  END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;


CREATE OR REPLACE FUNCTION gn_imports.delete_static_source(
    tablename character varying, id_source int)
  RETURNS boolean AS
$BODY$
  DECLARE
  
    v_error_stack text;
    start_time timestamp;
  BEGIN
    start_time := (SELECT clock_timestamp());

    DROP TABLE IF EXISTS tmp_process_import;
    CREATE TEMP TABLE tmp_process_import (
        id_synthese int, 
        entity_source_pk_value varchar, 
        cd_nom int,
        action char(1),
        idareas int[]
    );

    -- Récupération des id_synthese qui vont être supprimé
    EXECUTE 
        'WITH deleted_row AS (
            SELECT s.id_synthese, s.entity_source_pk_value, s.cd_nom, array_agg(id_area) as id_areas
            FROM gn_synthese.synthese s
            JOIN ' ||tablename || ' d 
            ON s.id_source = ' ||id_source || ' AND s.entity_source_pk_value = d.entity_source_pk_value::varchar
            JOIN gn_synthese.cor_area_synthese cor
            ON  s.id_synthese = cor.id_synthese
            GROUP BY s.id_synthese, s.entity_source_pk_value, s.cd_nom
        )
        INSERT INTO tmp_process_import (id_synthese, entity_source_pk_value, cd_nom, action, idareas)
        SELECT id_synthese, entity_source_pk_value, cd_nom, ''D'' as action, id_areas
        FROM deleted_row
        ';

    --Suppression de cor_area_taxon et cor_area_synthese
    RAISE NOTICE 'delete data : %', clock_timestamp();
    
    ALTER TABLE gn_synthese.synthese DISABLE TRIGGER tri_del_area_synt_maj_corarea_tax;

    DELETE FROM gn_synthese.cor_area_taxon s
    USING tmp_process_import d 
    WHERE s.cd_nom = d.cd_nom AND s.id_area = ANY (idareas);

    DELETE FROM gn_synthese.cor_area_synthese s
    USING tmp_process_import d 
    WHERE s.id_synthese = d.id_synthese;

    DELETE FROM gn_synthese.synthese s
    USING tmp_process_import d 
    WHERE s.id_synthese = d.id_synthese;
    
    INSERT INTO gn_synthese.cor_area_taxon (cd_nom, nb_obs, id_area, last_date)
    SELECT s.cd_nom, count(DISTINCT s.id_synthese), cor.id_area,  max(s.date_min)
    FROM gn_synthese.cor_area_synthese cor
    JOIN gn_synthese.synthese s 
    ON s.id_synthese = cor.id_synthese
    JOIN tmp_process_import d 
    ON s.cd_nom = d.cd_nom AND cor.id_area = ANY (idareas)
    JOIN taxonomie.taxref t
    ON t.cd_nom = s.cd_nom
    GROUP BY cor.id_area, s.cd_nom;
    
    ALTER TABLE gn_synthese.synthese ENABLE TRIGGER tri_del_area_synt_maj_corarea_tax;


    RAISE NOTICE 'START %', start_time;
    INSERT INTO gn_imports.gn_imports_log (
        table_name, success, error_msg, start_time, end_time, nb_delete
    )
    SELECT 
        tablename, true, NULL, start_time, clock_timestamp(), 
        count(*) FILTER (WHERE action='D') as nb_delete
    FROM tmp_process_import;
    
    RAISE NOTICE 'END : %', clock_timestamp();
    RETURN true;
EXCEPTION
   WHEN OTHERS THEN
    RAISE NOTICE 'Error during delete process .... ';
    GET STACKED DIAGNOSTICS v_error_stack = PG_EXCEPTION_CONTEXT;
    RAISE WARNING 'The stack trace of the error is: "%"', v_error_stack;
    
    ALTER TABLE gn_synthese.synthese ENABLE TRIGGER tri_del_area_synt_maj_corarea_tax;
    
    INSERT INTO gn_imports.gn_imports_log (table_name, success, error_msg, start_time, end_time)
    VALUES (tablename, false, v_error_stack, start_time, clock_timestamp());
    
    RETURN false;
  END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
