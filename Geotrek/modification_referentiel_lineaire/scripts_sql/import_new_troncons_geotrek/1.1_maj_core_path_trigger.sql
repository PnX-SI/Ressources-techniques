---------- EXÉCUTION DES TRIGGERS DE core_path POUR ACTIVER LES DÉCOUPAGES AUTOMATIQUES DE GEOTREK
DO $$DECLARE r record;
DECLARE
	v_state   TEXT;
    v_msg     TEXT;
    v_detail  TEXT;
    v_hint    TEXT;
    v_context TEXT;
BEGIN
	FOR r IN (
		SELECT *
		  FROM core_path
		 WHERE date_update = (SELECT max(date_update) FROM core_path LIMIT 1)
		 ORDER BY id
		 LIMIT MY_LIMIT OFFSET MY_OFFSET
	) LOOP
		BEGIN
			UPDATE core_path SET geom = geom WHERE id = r.id;
			-- RAISE NOTICE 'DO';
		EXCEPTION
			WHEN OTHERS THEN
				get stacked diagnostics
				v_state   = returned_sqlstate,
				v_msg     = message_text,
				v_detail  = pg_exception_detail,
				v_hint    = pg_exception_hint,
				v_context = pg_exception_context;
		raise notice E'Erreur :
			state  : %
			message: %
			detail : %
			hint   : %
			context: %',
			v_state, v_msg, v_detail, v_hint, v_context;
		END;
	END LOOP;
END$$;

