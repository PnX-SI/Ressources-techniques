
CREATE SCHEMA import_synthese;

CREATE TABLE import_synthese.t_synchronisation_configs (
 id_synchro serial PRIMARY KEY,
 code_name varchar(250) NOT NULL UNIQUE,
 table_name varchar(250),
 with_observers BOOLEAN DEFAULT (FALSE)
);

CREATE TABLE import_synthese.t_synchronisation_logs (
	id_log serial PRIMARY KEY,
	id_synchro int REFERENCES import_synthese.t_synchronisation_configs (id_synchro),
	date_synchro TIMESTAMP DEFAULT (NOW()),
	success BOOLEAN DEFAULT (FALSE)
);


CREATE OR REPLACE FUNCTION import_synthese.fct_sync_synthese(
  code_sync TEXT
) 
RETURNS BOOLEAN
 LANGUAGE plpgsql AS
$$
DECLARE
   -- Fonction permettant d'importer des sources de données "externes" dans la synthèse
   --   Elle permet de gérer les données de sources actives
   --       Insertion des données non présentent dans la synthese
   --       Modification des données qui ont été modifiées depuis la dernière synchro
   --       Suppression des données qui ne sont plus présentent dans la source
   --   L'identification des données se fait à partir du champ entity_source_pk_value et de id_source
   --       C'est champs doivent donc être unique et avoir une pérénité au niveau de la source

    _insertfield text; --prepared field to insert
    _updatefield text; --prepared field to insert
    _selectfield text; --prepared field in select clause
    _sqlimport text; --returned query AS text
    mysource_table TEXT; --source schema.table name
    _with_observers BOOLEAN; --proceed observers or not
    _last_sync TIMESTAMP; --date of the last sync
    _id_log INt; -- Id of the current log entry
    ssname text; --source schema name    
    stname text; --source table name
BEGIN

-- @ TODO fonction de test des données
--  Table existe bien, les données sont valides (Champ not null)
  SELECT  table_name, with_observers, COALESCE(MAX(date_synchro) FILTER (WHERE success), '0001-01-01')
	INTO mysource_table, _with_observers, _last_sync
  FROM import_synthese.t_synchronisation_configs c
  LEFT OUTER JOIN import_synthese.t_synchronisation_logs l
  ON c.id_synchro = l.id_synchro
  WHERE code_name = code_sync
  GROUP BY table_name, with_observers;

   --test si la table source est fournie sinon on retourne un message d'erreur
  IF length(mysource_table) > 0 THEN
    --split schema.table n deux chaines
    SELECT split_part(mysource_table, '.', 1) INTO ssname;
    SELECT split_part(mysource_table, '.', 2) INTO stname;
  ELSE
      BEGIN
          RAISE WARNING 'ERREUR : %', 'Vous devez passer en paramètre une table source et une table de destination.';
      END;
  END IF;

	INSERT INTO import_synthese.t_synchronisation_logs (id_synchro)
	SELECT id_synchro
	FROM import_synthese.t_synchronisation_configs c
	WHERE code_name = code_sync
	RETURNING id_log INTO _id_log;
	
   
  -- préparation des requêtes
  SELECT 
    string_agg(c.column_name, ',') AS sql_insert_col,
    string_agg('d.' || c.column_name, ',') AS sql_insert_cmd,
    string_agg(c.column_name || ' = d.' || c.column_name, ',') AS sql_update
    INTO _insertfield, _selectfield, _updatefield
  FROM (
    SELECT *
    FROM information_schema.columns  
    WHERE table_schema = ssname AND table_name = stname
      AND NOT column_name = 'id_synthese'
  ) c
  JOIN (
    SELECT *
    FROM information_schema.columns  
    WHERE table_schema = 'gn_synthese' AND table_name = 'synthese'
  ) s
  ON s.column_name = c.column_name;
  

  -- Création d'une table temporaire permettant de réaliser le suivis des opérations
  BEGIN
	  CREATE TEMP TABLE IF NOT EXISTS synt_ids (
	    id_synthese int, 
	    action char(1),
	    entity_source_pk_value varchar
	  );
	  TRUNCATE TABLE synt_ids;

	  ALTER TABLE gn_synthese.synthese DISABLE TRIGGER ALL;
	  

	  -- mise à jour des données
	  RAISE NOTICE 'Mise à jour des données';
	  EXECUTE FORMAT(
	    'WITH d AS (
	      SELECT %s FROM %s d
	      WHERE meta_update_date > %L
	    ), cmd AS (
	      UPDATE gn_synthese.synthese s SET %s
	      FROM (
		SELECT 
		  s.id_synthese, 
		  d.*
		FROM d
		JOIN gn_synthese.synthese s
		ON (s.entity_source_pk_value = d.entity_source_pk_value::varchar AND s.id_source = d.id_source)
	      ) d
	      WHERE d.id_synthese = s.id_synthese
	      RETURNING s.id_synthese, d.entity_source_pk_value
	    ) INSERT INTO synt_ids SELECT id_synthese, ''U'', entity_source_pk_value::varchar FROM cmd;',
	    _selectfield, mysource_table, _last_sync, _updatefield
	  );
		
	  -- insertion des données

	  RAISE NOTICE 'Insertion des données';
	  EXECUTE FORMAT(
	    'WITH source AS (
			SELECT DISTINCT id_source FROM %s d
		), data AS (
			SELECT DISTINCT %s
			FROM %s d
			LEFT OUTER JOIN (
				SELECT * FROM gn_synthese.synthese s WHERE id_source IN (SELECT id_source FROM source)
			) s
			ON s.entity_source_pk_value = d.entity_source_pk_value AND s.id_source = d.id_source 
			WHERE s.id_synthese IS NULL
		), cmd AS (
			INSERT INTO gn_synthese.synthese (%s)
			SELECT *
			FROM data
			RETURNING id_synthese, entity_source_pk_value
		) INSERT INTO synt_ids SELECT id_synthese, ''I'',  entity_source_pk_value::varchar FROM cmd;',
	    mysource_table, _selectfield, mysource_table, _insertfield
	  );
	  
	  -- suppression des données
	  RAISE NOTICE 'Suppression des données';
	  EXECUTE FORMAT(
	    'WITH d AS (
	      SELECT id_synthese
	      FROM (
			SELECT id_synthese, id_source, entity_source_pk_value
			FROM gn_synthese.synthese s 
			WHERE id_source IN ( SELECT DISTINCT id_source FROM %s d)
	      )s
	      LEFT OUTER JOIN %s d
	      ON d.id_source = s.id_source AND d.entity_source_pk_value::varchar = s.entity_source_pk_value
	      WHERE d.entity_source_pk_value IS NULL
	    ), cmd AS (
	      DELETE FROM gn_synthese.synthese sd
	      USING d
	      WHERE d.id_synthese = sd.id_synthese
	      RETURNING sd.id_synthese
	    ) INSERT INTO synt_ids SELECT id_synthese, ''D'', NULL FROM cmd;',
	    mysource_table, mysource_table
	  );
	  
	  -- Si cor_observers
	  IF _with_observers
		AND ( 
		    SELECT count(*)
		    FROM information_schema.columns  
		    WHERE table_schema = ssname AND table_name = stname AND column_name = 'id_observers'
		) > 0
	  THEN 
		  RAISE NOTICE 'Traitement cor_observer_synthese';
		  
		  DELETE FROM gn_synthese.cor_observer_synthese
		  WHERE id_synthese IN (SELECT id_synthese FROM synt_ids);

		  EXECUTE FORMAT(
		    'INSERT INTO gn_synthese.cor_observer_synthese (id_synthese, id_role)
			SELECT  d.id_synthese, d.id_role
			FROM (
				SELECT id_synthese, unnest(id_observers)::int AS id_role
				FROM %s d
				JOIN synt_ids s
				ON s.entity_source_pk_value = d.entity_source_pk_value::varchar
			)d
			JOIN utilisateurs.t_roles r
			ON r.id_role = d.id_role;',
		    mysource_table
		  );
	  END IF;

	  --Mise à jour des données liées cor_area_synthese
	  RAISE NOTICE 'Traitement cor_area_synthese';
	  DELETE FROM gn_synthese.cor_area_synthese
	  WHERE id_synthese IN (SELECT id_synthese FROM synt_ids);

	  INSERT INTO gn_synthese.cor_area_synthese SELECT
	      s.id_synthese,
	      a.id_area
	  FROM ref_geo.l_areas a
	  JOIN gn_synthese.synthese s ON st_intersects(s.the_geom_local, a.geom)
	  JOIN synt_ids m ON m.id_synthese = s.id_synthese;


	  --Mise à jour des données liées taxons_synthese_autocomplete
	  RAISE NOTICE 'Traitement taxons_synthese_autocomplete';
	  DELETE FROM gn_synthese.taxons_synthese_autocomplete auto
	  WHERE NOT  auto.cd_nom IN (
	  SELECT DISTINCT cd_nom 
	  FROM gn_synthese.synthese
	  );

	  WITH missing_cd_nom AS (
	    SELECT DISTINCT s.cd_nom
	    FROM gn_synthese.synthese s
	    LEFT OUTER JOIN gn_synthese.taxons_synthese_autocomplete auto
	    ON s.cd_nom = auto.cd_nom
	    WHERE auto.cd_nom IS NULL
	  )
	  INSERT INTO gn_synthese.taxons_synthese_autocomplete
	  SELECT t.cd_nom,
	    t.cd_ref,
	    concat(t.lb_nom, ' = <i>', t.nom_valide, '</i>') AS search_name,
	    t.nom_valide,
	    t.lb_nom,
	    t.regne,
	    t.group2_inpn
	  FROM taxonomie.taxref t  
	  WHERE cd_nom IN (SELECT cd_nom FROM missing_cd_nom)
	  UNION
	  SELECT t.cd_nom,
	  t.cd_ref,
	  concat(t.nom_vern, ' =  <i> ', t.nom_valide, '</i>' ) AS search_name,
	  t.nom_valide,
	  t.lb_nom,
	  t.regne,
	  t.group2_inpn
	  FROM taxonomie.taxref t  
	  WHERE t.nom_vern IS NOT NULL AND cd_nom IN (SELECT cd_nom FROM missing_cd_nom);

	  ALTER TABLE gn_synthese.synthese ENABLE TRIGGER ALL;

	  UPDATE import_synthese.t_synchronisation_logs SET success = TRUE 
	  WHERE id_log = _id_log;
	  
	  RETURN TRUE;

	EXCEPTION when others then 
		
		ALTER TABLE gn_synthese.synthese ENABLE TRIGGER ALL;
		RAISE NOTICE '% %', SQLERRM, SQLSTATE;
		RETURN FALSE;
	  
	end;

  RETURN FALSE;
END $$;


