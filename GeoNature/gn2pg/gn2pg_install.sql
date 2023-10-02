/* Création d'un schema dédié à gn2pg */
CREATE SCHEMA IF NOT EXIST gn2pg;

/* Création de la table des logs */ 
CREATE TABLE IF NOT EXISTS gn2pg.log
(
    id integer NOT NULL DEFAULT nextval('gn2pg.log_id_seq'::regclass),
    date timestamp without time zone DEFAULT now(),
    statut character varying(32) COLLATE pg_catalog."default",
    message text COLLATE pg_catalog."default",
    CONSTRAINT log_pkey PRIMARY KEY (id)
);

/* Création de la fonction permettant le téléchagement des données */
CREATE OR REPLACE FUNCTION gn2pg.gn2pg(
	gn_domain text,
	export_id integer,
	token text,
	destination_schema text,
	destination_table text,
	filters text DEFAULT NULL::text)
    RETURNS void
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
DECLARE http_request text;
--DECLARE token text;
DECLARE tmp_cols text;
DECLARE cols text[];
DECLARE loop_index integer :=0;
DECLARE nb_data_exported integer;
DECLARE _message text;
DECLARE _context text;
BEGIN
	/* Log start sync */
	INSERT INTO gn2pg.log (date, statut, message) VALUES (TIMEOFDAY()::timestamp, 'start', 'Start downloading datas for exports #' || export_id || ' from ' || gn_domain);
	
	/* Drop existing result table */
	EXECUTE FORMAT('DROP TABLE IF EXISTS %I.%I', destination_schema, destination_table);
	
	LOOP
		RAISE NOTICE 'Downloading data % - %', loop_index * 1000, loop_index * 1000 + 1000; 
		-- Reset temporary table
		EXECUTE (
				'DROP TABLE IF EXISTS tmp_export_'|| destination_table ||';
				 CREATE TEMP TABLE tmp_export_' || destination_table || '(data json);'
				);
				
		-- Preparing curl command for getting data from export_id
		IF filters IS NOT NULL THEN
			http_request := concat('curl --insecure -X GET "https://', gn_domain,'/geonature/api/exports/api/', export_id,'?token=',token,'&limit=1000&offset=',loop_index::text,'&',replace(filters, ' ', '%20'),'" -H "Accept: application/json" --http2'::text);
		ELSE 
			http_request := concat('curl --insecure -X GET "https://', gn_domain,'/geonature/api/exports/api/', export_id,'?token=',token,'&limit=1000&offset=',loop_index,'" -H "Accept: application/json"');
		END IF;
		
		-- Exec curl command and write json result in temporary table
		EXECUTE 'COPY tmp_export_' || destination_table || ' FROM PROGRAM ''' || http_request || ''' CSV QUOTE E''\x01'' DELIMITER E''\x02'';';
		
		-- First loop ?
		IF loop_index = 0 THEN
			/* Get list of column and force type to text */
			EXECUTE FORMAT('
				SELECT string_agg(column_name, '' TEXT, '') || '' TEXT'' 
				FROM (
					SELECT json_object_keys(((data->>''items'')::json->0)::json) as column_name FROM tmp_export_%I a
				) b'
				, destination_table
			) INTO tmp_cols;
		
			/* Create table and insert data */
			EXECUTE FORMAT('
				CREATE TABLE %I.%I AS 
				SELECT x.* 
				FROM 
					tmp_export_%I
					CROSS JOIN LATERAL json_to_recordset((data->>''items'')::json) as x(' || tmp_cols || ')'
				,destination_schema, destination_table, destination_table
			);
		
		ELSE
			-- Other, just INSERT data 
			EXECUTE FORMAT('
				INSERT INTO %I.%I 
				SELECT x.* 
				FROM 
					tmp_export_%I
					CROSS JOIN LATERAL json_to_recordset((data->>''items'')::json) as x(' || tmp_cols || ')'
				,destination_schema, destination_table, destination_table
			);
		END IF;
		
		-- get number of exported data
		EXECUTE FORMAT('SELECT json_array_length((data->>''items'')::json) FROM tmp_export_%I', destination_table) INTO nb_data_exported;
		
		-- If less than 1000 recard -> end of GN-View
		IF nb_data_exported < 1000 THEN
			EXIT;  -- exit loop
		END IF;
		loop_index := loop_index + 1;
	END LOOP;
	
	/* Log end sync */
	INSERT INTO gn2pg.log (date, statut, message) VALUES (TIMEOFDAY()::timestamp, 'end', 'End of downloading datas for exports #' || export_id || ' from ' || gn_domain);

EXCEPTION 
	--Log error
	WHEN OTHERS THEN
    	GET STACKED DIAGNOSTICS
			_message := MESSAGE_TEXT,
			_context := PG_EXCEPTION_CONTEXT;
			
	INSERT INTO gn2pg.log (date, statut, message) VALUES (TIMEOFDAY()::timestamp, 'error', 'Error during downloading datas for exports #' || export_id || ' from ' || gn_domain || 'with message : ' || _message || ' - ' || _context);

END;
$BODY$;


