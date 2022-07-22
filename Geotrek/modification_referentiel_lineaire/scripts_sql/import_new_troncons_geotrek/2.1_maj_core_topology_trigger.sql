---------- EXÉCUTION DE LA FONCTION update_geometry_of_topology()
---------- sur tous les core_topology d'itinéraires pour mettre à jour leur géométrie
---------- selon les nouveaux pathaggregation
DO $$DECLARE r record;
DECLARE
    v_state   TEXT;
    v_msg     TEXT;
    v_detail  TEXT;
    v_hint    TEXT;
    v_context TEXT;
BEGIN
  FOR r IN SELECT * FROM core_topology LOOP
    BEGIN
      PERFORM update_geometry_of_topology(r.id);
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
        context: %', v_state, v_msg, v_detail, v_hint, v_context;
  END;
  END LOOP;
END$$;

---------- RENDRE VISIBLES TOUS LES CORE_PATH UTILISÉS DANS UN core_pathaggregation
---------- Un mécanisme sur lequel nous n'avons pas investigué semble en effet désactiver
---------- la visibilité de certains `core_path` lors des requêtes d'agrégation des réseaux.
UPDATE core_path
   SET visible = TRUE
 WHERE id IN (SELECT path_id FROM core_pathaggregation);
