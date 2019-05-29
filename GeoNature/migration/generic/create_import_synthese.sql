
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

CREATE OR REPLACE FUNCTION gn_imports.import_static_source(
    tablename character varying,
    idsource integer,
    iddataset integer)
  RETURNS boolean AS
$BODY$
  DECLARE
    i int;
    insert_cmd text;
    insert_columns text;
    select_cmd text;
    select_columns text;
    update_columns text;
    update_cmd text;

    v_error_stack text;
    start_time timestamp;

    --Error
    v_state   TEXT;
    v_msg     TEXT;
    v_detail  TEXT;
    v_hint    TEXT;
    v_context TEXT;
  BEGIN
  
    -- ######################################### ---
    --  TESTS
    -- ######################################### ---
    -- Table existe
    -- Champs obligatoires existent
    -- Champ entity_source_pk_value bien unique
    BEGIN
        IF NOT EXISTS (
            SELECT DISTINCT 1
            FROM pg_attribute
            WHERE  attrelid = tablename::regclass
               AND attname::text IN ('entity_source_pk_value')
        ) THEN
            RAISE EXCEPTION 'Field  entity_source_pk_value is mandatory';
        ELSE
            EXECUTE format('
                SELECT 1 
                FROM %1$s
                GROUP BY entity_source_pk_value
                HAVING count(*) >1
            ', tablename);
            
            GET DIAGNOSTICS i = ROW_COUNT;
            IF i>0 THEN  
                RAISE EXCEPTION 'Field entity_source_pk_value must have unique value';
            END IF;
        END IF;
    EXCEPTION WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS
            v_state   = RETURNED_SQLSTATE,
            v_msg     = MESSAGE_TEXT,
            v_detail  = PG_EXCEPTION_DETAIL,
            v_hint    = PG_EXCEPTION_HINT,
            v_context = PG_EXCEPTION_CONTEXT;
        
        RAISE EXCEPTION '%', v_msg
            USING HINT = v_hint;
    END;

    
   -- ######################################### ---
   --   CREATION DES REQUETES
   -- ######################################### ---

   
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
        WHERE table_schema || '.' || table_name = 'gn_synthese.synthese'
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
    

   -- ######################################### ---
   --   IMPORT DES DONNEES
   -- ######################################### ---

    -- désactivation des triggers pour des questions de perfs
    ALTER TABLE gn_synthese.synthese DISABLE TRIGGER ALL;
    
    RAISE NOTICE 'Import data : %', clock_timestamp();
 
    -- Création d'une table temporaire résumant les données importées
    DROP TABLE IF EXISTS tmp_process_import;
    CREATE TEMP TABLE tmp_process_import (
        id_synthese int, 
        entity_source_pk_value varchar, 
        cd_nom int,
        action char(1)
    );

    -- Insertion des données dans la synthese
    EXECUTE 'WITH inserted_rows as (' || 
            insert_cmd || insert_columns || ') ' || select_cmd || select_columns  || 
            ' FROM ' || tablename ||' d 
            LEFT OUTER JOIN gn_synthese.synthese s
            ON d.entity_source_pk_value::varchar = s.entity_source_pk_value AND id_source = ' || idsource || '
            WHERE s.id_synthese IS NULL 
            RETURNING id_synthese, entity_source_pk_value::varchar, cd_nom
        )
        INSERT INTO tmp_process_import
        SELECT id_synthese, entity_source_pk_value, cd_nom, ''I'' as action
        FROM inserted_rows'
    ;

    -- Mise à jour des données dans la synthese
    EXECUTE 'WITH updated_rows as (
            UPDATE gn_synthese.synthese s SET ' || update_cmd || update_columns ||
            ' FROM ' || tablename || ' d
            LEFT OUTER JOIN tmp_process_import t
            ON t.entity_source_pk_value = d.entity_source_pk_value::varchar
            WHERE 
                t.entity_source_pk_value IS NULL
                AND id_source = ' || idsource || '
                AND d.entity_source_pk_value::varchar = s.entity_source_pk_value
            RETURNING s.id_synthese, s.entity_source_pk_value, s.cd_nom
        )
        INSERT INTO tmp_process_import
        SELECT id_synthese, entity_source_pk_value, cd_nom, ''U'' as action
        FROM updated_rows'
    ;

    
   -- ######################################### ---
   --   Traitements des données importées 
   --       pour simuler les triggers désactivés
   -- ######################################### ---

   -- #########
   -- cor_area_synthese et cor_area_taxon
   -- #########

    RAISE NOTICE 'Update cor_area_synthese and cor_area_taxon : %', clock_timestamp();

    -- Déactivation des triggers de cor_area_synthese pour des questions de perfs
    ALTER TABLE gn_synthese.cor_area_synthese DISABLE TRIGGER ALL;
    COPY (
        SELECT DISTINCT c.cd_nom, ca.id_area
        FROM gn_synthese.cor_area_synthese ca
        JOIN tmp_process_import c
        ON c.id_synthese = ca.id_synthese
        ORDER BY c.cd_nom, ca.id_area
    )
    TO '/tmp/to_del_cor_area_taxon.csv' 
    WITH CSV HEADER;
    
    -- Suppression des données de gn_synthese.cor_area_synthese qui doivent être recalculées
    DELETE FROM gn_synthese.cor_area_synthese
    WHERE id_synthese IN (SELECT id_synthese FROM tmp_process_import);
    
    -- Import des données de gn_synthese.cor_area_synthese
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

    -- Suppression des données de gn_synthese.cor_area_taxon qui doivent être recalculées
    WITH data AS (
        SELECT DISTINCT c.cd_nom, ca.id_area
        FROM gn_synthese.cor_area_synthese ca
        JOIN  tmp_process_import c
        ON c.id_synthese = ca.id_synthese
    )
    DELETE FROM gn_synthese.cor_area_taxon c
    USING data
    WHERE c.cd_nom = data.cd_nom AND c.id_area  = data.id_area;

    -- Import des données de gn_synthese.cor_area_taxon
    COPY (
       SELECT DISTINCT c.cd_nom, ca.id_area
        FROM gn_synthese.cor_area_synthese ca
        JOIN  tmp_process_import c
        ON c.id_synthese = ca.id_synthese
        ORDER BY c.cd_nom, ca.id_area
    )
    TO '/tmp/to_add_cor_area_taxon.csv' 
    WITH CSV HEADER;

    
    WITH data AS (
        SELECT DISTINCT c.cd_nom, ca.id_area
        FROM gn_synthese.cor_area_synthese ca
        JOIN  tmp_process_import c
        ON c.id_synthese = ca.id_synthese
        ORDER BY c.cd_nom, ca.id_area
    )
    INSERT INTO gn_synthese.cor_area_taxon (id_area, cd_nom, last_date, nb_obs)
    SELECT cor.id_area, s.cd_nom,  max(s.date_min) AS last_date, count(DISTINCT s.id_synthese) AS nb_obs
    FROM gn_synthese.synthese s 
    JOIN gn_synthese.cor_area_synthese cor
        ON s.id_synthese = cor.id_synthese
    JOIN taxonomie.taxref t 
        ON s.cd_nom = t.cd_nom
    JOIN data c
        ON s.cd_nom = c.cd_nom AND cor.id_area = c.id_area
    GROUP BY cor.id_area, s.cd_nom
    ORDER BY s.cd_nom, id_area; 
    
    -- #########
    -- taxons_synthese_autocomplete
    -- #########
    RAISE NOTICE 'Update taxons_synthese_autocomplete : %', clock_timestamp();
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

    WITH old_cd_nom AS (
        SELECT DISTINCT c.cd_nom
        FROM gn_synthese.taxons_synthese_autocomplete c
        LEFT OUTER JOIN  gn_synthese.synthese s
        ON c.cd_nom = s.cd_nom
        WHERE s.cd_nom IS NULL 
    )
    DELETE FROM gn_synthese.taxons_synthese_autocomplete s
    WHERE s.cd_nom IN (SELECT cd_nom FROM old_cd_nom);

   -- ######################################### ---
   --   Import des observateurs 
   --       si une colonne ids_observateur existe
   -- ######################################### ---
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
        
        DELETE FROM gn_synthese.cor_observer_synthese
        WHERE id_synthese IN (SELECT id_synthese FROM tmp_process_import);
        
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

    
    -- ######################################### ---
    --   Post opérations
    -- ######################################### ---

    -- Réactivation des triggers
    ALTER TABLE gn_synthese.synthese ENABLE TRIGGER ALL;
    ALTER TABLE gn_synthese.cor_area_synthese ENABLE TRIGGER ALL;

    -- Enregistrement dans la table log de l'import réalisé
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
   
   -- ######################################### ---
   --   Traitement des erreurs
   -- ######################################### ---
    RAISE NOTICE 'Error during import process .... ';
            GET STACKED DIAGNOSTICS
            v_state   = RETURNED_SQLSTATE,
            v_msg     = MESSAGE_TEXT,
            v_detail  = PG_EXCEPTION_DETAIL,
            v_hint    = PG_EXCEPTION_HINT,
            v_context = PG_EXCEPTION_CONTEXT;
    raise WARNING E'Got exception:
            state  : %
            message: %
            detail : %
            hint   : %
            context: %', v_state, v_msg, v_detail, v_hint, v_context;
  
    -- Activation de tous les triggers potentiellement désactivés
    ALTER TABLE gn_synthese.synthese ENABLE TRIGGER ALL;
    ALTER TABLE gn_synthese.cor_observer_synthese ENABLE TRIGGER ALL;
    ALTER TABLE gn_synthese.cor_area_synthese ENABLE TRIGGER ALL;

    -- Enregistrement dans la table log de l'import réalisé avec la mention succes=false
    INSERT INTO gn_imports.gn_imports_log (table_name, success, error_msg, start_time, end_time)
    VALUES (tablename, false, v_msg || ' ' || v_error_stack, start_time, clock_timestamp());
    
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