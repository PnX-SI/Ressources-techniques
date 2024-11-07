/**
 * Création d'un schema dédié
 */ 
CREATE SCHEMA IF NOT EXISTS gbif2pg;

/**
 * Création de la table de LOG
 */
CREATE TABLE IF NOT EXISTS gbif2pg.log
(
    id serial,
    date timestamp without time zone DEFAULT now(),
    statut character varying(32) COLLATE pg_catalog."default",
    message text COLLATE pg_catalog."default",
    CONSTRAINT log_pkey PRIMARY KEY (id)
);

/**
 * Création de la fonction de récupération des occurrences
 */
CREATE OR REPLACE FUNCTION gbif2pg.get_occurrences(
	destination_schema text,
	destination_table text,
	filters text DEFAULT NULL::text)
    RETURNS void
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
DECLARE http_request text;
DECLARE tmp_cols text;
DECLARE loop_index integer :=0;
DECLARE nb_data_exported integer;
DECLARE _message text;
DECLARE _context text;
BEGIN
	/* Log start sync */
	INSERT INTO gbif2pg.log (date, statut, message) VALUES (TIMEOFDAY()::timestamp, 'start', 'Start downloading datas from gbif');
	
	LOOP
		RAISE NOTICE 'Downloading data % - %', loop_index * 300, loop_index * 300 + 300; 
		-- Reset temporary table
		EXECUTE (
			'DROP TABLE IF EXISTS tmp_export_'|| destination_table ||';
			 CREATE TEMP TABLE tmp_export_' || destination_table || '(data json);'
		);

		-- Ajouter le filtre "&country=FR&country=RE&country=GF&country=GP" pour ajouter les données de la métropole, réunion et/ou Guyane
		http_request := concat('curl --insecure -X GET "https://api.gbif.org/v1/occurrence/search?' || filters || '&limit=300&offset=',loop_index * 300,'" -H "Accept: application/json"');

		-- Affichage de la commande curl (pour debuggage)
		RAISE NOTICE 'http_request : %', http_request;
		
		-- Execution de la commande curl et intégration du résultat dans une table temporaire
		EXECUTE 'COPY tmp_export_' || destination_table || ' FROM PROGRAM ''' || http_request || ''' CSV QUOTE E''\x01'' DELIMITER E''\x02'';';

		-- Récuypération du nombre de données reçu
		EXECUTE FORMAT('SELECT json_array_length((data->>''results'')::json) FROM tmp_export_%I', destination_table) INTO nb_data_exported;
		-- Si on est sur la première boucle
		IF loop_index = 0 THEN
			-- Récupération et structuration de la liste des colonnes
			EXECUTE FORMAT('
				SELECT ''"'' || string_agg(column_name, ''" TEXT, "'') || ''"'' || '' TEXT'' 
				FROM (
					SELECT json_object_keys(((data->>''results'')::json->0)::json) as column_name FROM tmp_export_%I a
				) b'
				, destination_table
			) INTO tmp_cols;

			-- Dans certain cas, le GBIF ne retourne pas le champ identifieedBy, il faut dont l'ajouter sinnon ça bloque le reste
			IF tmp_cols NOT LIKE '%"identifiedBy" TEXT%' THEN
				tmp_cols = tmp_cols || ', "identifiedBy" TEXT';		
			END IF;
		END IF;

		
		-- On supprimmer les données que l'on aurait déjà (et qui aurait donc fait l'objet d'une modification depuis la dernière synchronisation)
		EXECUTE FORMAT('
			DELETE FROM %I.%I 
			WHERE identifier IN (
				SELECT x."key" 
				FROM 
					tmp_export_%I
					CROSS JOIN LATERAL json_to_recordset((data->>''results'')::json) as x(' || tmp_cols || ')
				
			)'
			,destination_schema, destination_table, destination_table );

		-- Insertion des données
		EXECUTE FORMAT('
				INSERT INTO %I.%I 
				SELECT
					x."key",
					x."datasetKey"::uuid,
					x."speciesKey"::integer,
					x."species",
					x."recordedBy",
					x."identifiedBy",
					x."eventDate",
					x."lastInterpreted"::timestamp,
					ST_SetSRID(ST_MakePoint( (x."decimalLongitude")::float, (x."decimalLatitude")::float), 4326),
					STRING_TO_ARRAY(REPLACE(REPLACE(REPLACE(x."issues", ''['', ''''), '']'',''''), ''"'','''' ),'','')
				FROM 
					tmp_export_%I
					CROSS JOIN LATERAL json_to_recordset((data->>''results'')::json) as x(' || tmp_cols || ')'
				,destination_schema, destination_table, destination_table
			);
		-- Si on a reçus moins de données que la taille de la page alors on est arrivé au bout
		IF nb_data_exported < 300 THEN
			EXIT;  -- exit loop
		END IF;
		loop_index := loop_index + 1;
	END LOOP;
	
	/* Log end sync */
	INSERT INTO gbif2pg.log (date, statut, message) VALUES (TIMEOFDAY()::timestamp, 'end', 'End of downloading datas from gbif'); 

EXCEPTION 
	--Log error
	WHEN OTHERS THEN
    	GET STACKED DIAGNOSTICS
			_message := MESSAGE_TEXT,
			_context := PG_EXCEPTION_CONTEXT;
			
	INSERT INTO gbif2pg.log (date, statut, message) VALUES (TIMEOFDAY()::timestamp, 'error', 'Error during downloading datas from gbif with message : ' || _message || ' - ' || _context);

END;
$BODY$;

/**
 * Création de la fonction de récupération des données relative à un jeu de données
 */
CREATE OR REPLACE FUNCTION gbif2pg.get_dataset(
	dataset_key text,
	destination_schema text,
	destination_table text)
    RETURNS void
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
DECLARE http_request text;
DECLARE _message text;
DECLARE _context text;
BEGIN
	/* Log start sync */
	INSERT INTO gbif2pg.log (date, statut, message) VALUES (TIMEOFDAY()::timestamp, 'start', 'Start downloading datas for dataset #' || dataset_key || ' from GBIF');
	
	-- Initialisation de la table temporaire
	EXECUTE (
			'DROP TABLE IF EXISTS tmp_export_'|| destination_table ||';
			CREATE TEMP TABLE tmp_export_' || destination_table || '(data json);'
		);
			
	-- Préparation de la requête Curl
	http_request := concat('curl --insecure -X GET "https://api.gbif.org/v1/dataset/', dataset_key,'" -H "Accept: application/json"');
	
	-- Execution de la commande curl et intégration du résultat dans une table temporaire
	EXECUTE 'COPY tmp_export_' || destination_table || ' FROM PROGRAM ''' || http_request || ''' CSV QUOTE E''\x01'' DELIMITER E''\x02'';';

	-- On supprimmer le dataset S'il  existe déjà dans la table
		EXECUTE FORMAT('
			DELETE FROM %I.%I 
			WHERE dataset_key IN (
				SELECT (data->>''key'')::uuid 
				FROM 
					tmp_export_%I)'
			,destination_schema, destination_table, destination_table );

	--  Insertion du datasets
	EXECUTE FORMAT('
		INSERT INTO %I.%I (
			dataset_key,
			name,
			description
		)
		SELECT 
			(data->>''key'')::uuid,
			data->>''title'',
			data->>''description''
		FROM 
			tmp_export_%I'
		,destination_schema, destination_table, destination_table
	);

	/* Log end sync */
	INSERT INTO gbif2pg.log (date, statut, message) VALUES (TIMEOFDAY()::timestamp, 'end', 'End of downloading dataset for GBIF');

EXCEPTION 
	--Log error
	WHEN OTHERS THEN
    	GET STACKED DIAGNOSTICS
			_message := MESSAGE_TEXT,
			_context := PG_EXCEPTION_CONTEXT;
			
	INSERT INTO gbif2pg.log (date, statut, message) VALUES (TIMEOFDAY()::timestamp, 'error', 'Error during downloading datas for dataset #' || dataset_key || ' with message : ' || _message || ' - ' || _context);

END;
$BODY$;

/**
 * Création de la procédure s'occupant de la première intégration
 * Créé les schéma et tables si non existant
 */
CREATE OR REPLACE PROCEDURE gbif2pg.first_import(
	IN destination_schema text,
	IN destination_occurrence_table text,
	IN destination_dataset_table text)
LANGUAGE 'plpgsql'
AS $BODY$
DECLARE table_occurrence_exists boolean;
DECLARE table_dataset_exists boolean;
DECLARE _message text;
DECLARE _context text;
BEGIN
	/* Log start sync */
	INSERT INTO gbif2pg.log (date, statut, message) VALUES (TIMEOFDAY()::timestamp, 'start', 'Start first inserting occurrences from gbif');

	-- Création du schema s'il n'existe pas déjà
	EXECUTE FORMAT('CREATE SCHEMA IF NOT EXISTS %I', destination_schema);

	-- Contrôle que les tables destinaitons existent et les créé le cas contraire
	EXECUTE FORMAT('SELECT EXISTS (
	   SELECT FROM information_schema.tables 
	   WHERE table_schema = ''%s''
	   AND table_name   = ''%s''
	 );', destination_schema, destination_occurrence_table) INTO table_occurrence_exists;

	IF table_occurrence_exists = FALSE THEN 
		EXECUTE FORMAT ('CREATE TABLE IF NOT EXISTS %I.%I
			(
			    identifier text COLLATE pg_catalog."default",
			    dataset_key uuid,
			    species_key integer,
			    species_name text COLLATE pg_catalog."default",
			    recorded_by text COLLATE pg_catalog."default",
			    identified_by text COLLATE pg_catalog."default",
			    event_date text COLLATE pg_catalog."default",
			    last_interpreted timestamp without time zone,
			    geom geometry(Geometry,4326),
    			issues text[] COLLATE pg_catalog."default"
			);', destination_schema, destination_occurrence_table);
	END IF;

	EXECUTE FORMAT('SELECT EXISTS (
	   SELECT FROM information_schema.tables 
	   WHERE table_schema = ''%s''
	   AND table_name   = ''%s''
	 );', destination_schema, destination_dataset_table) INTO table_dataset_exists;

	 IF table_dataset_exists = FALSE THEN 
		EXECUTE FORMAT ('CREATE TABLE IF NOT EXISTS %I.%I
			(
			    dataset_key uuid,
			    name text COLLATE pg_catalog."default",
			    description text COLLATE pg_catalog."default"
			);', destination_schema, destination_dataset_table);
	 END IF;

	-- Insertion des données précédemment intégrées dans PostgreSQL via ogr2ogr 
	EXECUTE FORMAT('
		INSERT INTO %I.%I (
			identifier,
		    dataset_key,
		    species_key,
		    species_name,
		    recorded_by,
		    identified_by,
		    event_date,
		    last_interpreted,
		    geom,
		    issues
		)
		SELECT
			gbifid,
			datasetkey::uuid,
			specieskey,
			species,
			recordedby,
			identifiedby,
			eventdate,
			lastinterpreted,
			ST_SetSRID(ST_MakePoint( (decimallongitude)::float, (decimallatitude)::float), 4326),
			STRING_TO_ARRAY(REPLACE(REPLACE(REPLACE(issue, ''['', ''''), '']'',''''), ''"'',''''),'','')
		FROM
			gbif2pg.tmp_occurrence_first_import
	', destination_schema, destination_occurrence_table);

	-- Execution de la fonction de récupération des dataset
	RAISE NOTICE 'Récupération des jeux de données';
    EXECUTE FORMAT('with d AS (
		select distinct dataset_key from %I.%I
	)
	select gbif2pg.get_dataset(dataset_key::text, ''%s'', ''%s'') 
	from d;'
	,destination_schema, destination_occurrence_table, destination_schema, destination_dataset_table);

/*EXCEPTION 
	--Log error
	WHEN OTHERS THEN
    	GET STACKED DIAGNOSTICS
			_message := MESSAGE_TEXT,
			_context := PG_EXCEPTION_CONTEXT;
			
	INSERT INTO gbif2pg.log (date, statut, message) VALUES (TIMEOFDAY()::timestamp, 'error', 'Error during downloading datas from gbif with message : ' || _message || ' - ' || _context);
*/
END;
$BODY$;

/**
 * Création de la procédure de synchronisation incrémentale
 */
CREATE OR REPLACE PROCEDURE gbif2pg.sync_from_gbif(
	IN destination_schema text,
	IN destination_occurrence_table text,
	IN destination_dataset_table text,
	IN filters text)
LANGUAGE 'plpgsql'
AS $BODY$
DECLARE last_interpreted timestamp;
begin

	EXECUTE FORMAT('SELECT max(last_interpreted) FROM %I.%I', destination_schema, destination_occurrence_table) INTO last_interpreted;
	RAISE NOTICE 'last_interpreted : %', last_interpreted;

	PERFORM gbif2pg.get_occurrences(destination_schema, destination_occurrence_table, filters || '&lastInterpreted=' || to_char(last_interpreted, 'yyyy-mm-dd') || ',' || to_char(now(), 'yyyy-mm-dd'));

	-- Execution de la fonction de récupération des dataset
	RAISE NOTICE 'Récupération des jeux de données';
    EXECUTE FORMAT('with d AS (
		select distinct dataset_key from %I.%I
	)
	select gbif2pg.get_dataset(dataset_key::text, ''%s'', ''%s'') 
	from d;'
	,destination_schema, destination_occurrence_table, destination_schema, destination_dataset_table);
end;
$BODY$;
