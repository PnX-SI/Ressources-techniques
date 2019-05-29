CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

ALTER TABLE md.protocole add  unique_dataset_id uuid NOT NULL DEFAULT uuid_generate_v4();
UPDATE  md.protocole SET unique_dataset_id = '4d331cae-65e4-4948-b0b2-a11bc5bb46c2' WHERE id_protocole = 1;



ALTER TABLE saisie.saisie_observation  ADD unique_uuid uuid NOT NULL DEFAULT uuid_generate_v4();
ALTER TABLE saisie.suivi_saisie_observation  ADD unique_uuid uuid NOT NULL DEFAULT uuid_generate_v4();


CREATE OR REPLACE FUNCTION saisie.alimente_suivi_saisie_observation()
  RETURNS trigger AS
$BODY$ 
  declare
  user_login text; BEGIN 
  user_login = outils.get_user();
    IF (TG_OP = 'DELETE') THEN 
      INSERT INTO saisie.suivi_saisie_observation 
      SELECT 'DELETE', now(), user_login, OLD.id_obs, OLD.date_obs, OLD.date_debut_obs, OLD.date_fin_obs, OLD.date_textuelle, OLD.regne, OLD.nom_vern, 
		OLD.nom_complet, OLD.cd_nom, OLD.effectif_textuel, OLD.effectif_min, OLD.effectif_max, OLD.type_effectif, 
		OLD.phenologie, OLD.id_waypoint, OLD.longitude, OLD.latitude, OLD.localisation, OLD.observateur, 
		OLD.numerisateur, OLD.validateur, OLD.structure, OLD.remarque_obs, OLD.code_insee, OLD.id_lieu_dit, 
		OLD.diffusable, OLD."precision", OLD.statut_validation, OLD.id_etude, OLD.id_protocole, OLD.effectif, 
		OLD.url_photo, OLD.commentaire_photo, OLD.decision_validation, OLD.heure_obs, OLD.determination, 
		OLD.elevation, OLD.geometrie, OLD.phylum, OLD.classe, OLD.ordre, OLD.famille, OLD.nom_valide, 
		OLD.qualification, OLD.comportement, OLD.unique_uuid;
      RETURN OLD; 
    ELSIF (TG_OP = 'UPDATE') OR (TG_OP = 'INSERT') THEN 
      INSERT INTO saisie.suivi_saisie_observation 
      SELECT TG_OP, now(), user_login, NEW.id_obs, NEW.date_obs, NEW.date_debut_obs, NEW.date_fin_obs, NEW.date_textuelle, NEW.regne, NEW.nom_vern, 
		NEW.nom_complet, NEW.cd_nom, NEW.effectif_textuel, NEW.effectif_min, NEW.effectif_max, NEW.type_effectif, 
		NEW.phenologie, NEW.id_waypoint, NEW.longitude, NEW.latitude, NEW.localisation, NEW.observateur, 
		NEW.numerisateur, NEW.validateur, NEW.structure, NEW.remarque_obs, NEW.code_insee, NEW.id_lieu_dit, 
		NEW.diffusable, NEW."precision", NEW.statut_validation, NEW.id_etude, NEW.id_protocole, NEW.effectif, 
		NEW.url_photo, NEW.commentaire_photo, NEW.decision_validation, NEW.heure_obs, NEW.determination, 
		NEW.elevation, NEW.geometrie, NEW.phylum, NEW.classe, NEW.ordre, NEW.famille, NEW.nom_valide, 
		NEW.qualification, NEW.comportement, NEW.unique_uuid;
      RETURN NEW;
    END IF; 
    RETURN NULL; 
  END; 
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;



-- 
CREATE OR REPLACE VIEW saisie.v_export_for_synthese_gn2 AS 
 SELECT i.date_insert,
    u.date_last_update,
    p.unique_dataset_id,
    s.id_obs,
    s.unique_uuid,
    s.date_obs,
    s.date_debut_obs,
    s.date_fin_obs,
    s.date_textuelle,
    s.regne,
    s.nom_vern,
    s.nom_complet,
    s.cd_nom,
    s.effectif_textuel,
    s.effectif_min,
    s.effectif_max,
    s.type_effectif,
    s.phenologie,
    s.id_waypoint,
    s.longitude,
    s.latitude,
    s.localisation,
    string_to_array(s.observateur, '&') AS ids_observateur,
    md.liste_nom_auteur(s.observateur) AS observateur,
    s.numerisateur AS id_numerisateur,
    md.liste_nom_auteur(s.numerisateur::character varying::text) AS numerisateur,
    s.validateur as id_validateur,
    md.liste_nom_auteur(s.validateur::character varying::text) AS validateur,
    s.structure,
    s.remarque_obs,
    s.code_insee,
    s.id_lieu_dit,
    s.diffusable,
    s."precision",
    s.statut_validation,
    s.id_etude,
    s.id_protocole,
    s.effectif,
    s.url_photo,
    s.commentaire_photo,
    s.decision_validation,
    s.heure_obs,
    s.determination,
    s.elevation,
    s.geometrie,
    s.phylum,
    s.classe,
    s.ordre,
    s.famille,
    s.nom_valide,
    s.qualification,
    s.comportement
FROM saisie.saisie_observation s
JOIN md.protocole p ON s.id_protocole = p.id_protocole
JOIN ( SELECT DISTINCT suivi_saisie_observation.id_obs,
    suivi_saisie_observation.date_operation AS date_insert
    FROM saisie.suivi_saisie_observation
    WHERE suivi_saisie_observation.operation = 'INSERT'::text) i ON s.id_obs = i.id_obs
LEFT JOIN ( SELECT DISTINCT suivi_saisie_observation.id_obs,
    max(suivi_saisie_observation.date_operation) AS date_last_update
    FROM saisie.suivi_saisie_observation
    WHERE suivi_saisie_observation.operation = 'UPDATE'::text
    GROUP BY suivi_saisie_observation.id_obs) u ON s.id_obs = u.id_obs
WHERE NOT regne = 'Habitat';


-- Vue données supprimées

CREATE OR REPLACE VIEW saisie.v_export_deleted_data AS 
SELECT id_obs as entity_source_pk_value, date_operation FROM saisie.suivi_saisie_observation WHERE operation = 'DELETE';

