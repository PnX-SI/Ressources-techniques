CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

ALTER TABLE md.protocole add   unique_dataset_id uuid NOT NULL DEFAULT uuid_generate_v4();
UPDATE  md.protocole SET unique_dataset_id = '4d331cae-65e4-4948-b0b2-a11bc5bb46c2' WHERE id_protocole = 1;



CREATE OR REPLACE VIEW saisie.v_export_for_synthese_gn2 AS 
 SELECT i.date_insert,
    u.date_last_update,
    s.id_obs,
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

