-- On crée une vue de toute les valeurs de listes de nomenclatures utilisés dans les différents champs de la table rnf_obs
CREATE OR REPLACE VIEW _import_serena.v_rnf_choi_obse_nomenclatures AS

WITH choi_list AS
(SELECT DISTINCT choi_list_id, 'protocole' as type_liste
	FROM _import_serena.rnf_choi
	JOIN _import_serena.rnf_obse ON rnf_choi.choi_id = rnf_obse.obse_pcole_choi_id
UNION
SELECT DISTINCT choi_list_id, 'validation' as type_liste
	FROM _import_serena.rnf_choi
	JOIN _import_serena.rnf_obse ON rnf_choi.choi_id = rnf_obse.obse_validat_choi_id
UNION
SELECT DISTINCT choi_list_id, 'confidentialite' as type_liste
	FROM _import_serena.rnf_choi
	JOIN _import_serena.rnf_obse ON rnf_choi.choi_id = rnf_obse.obse_confid_choi_id
UNION
SELECT DISTINCT choi_list_id, 'sexe' as type_liste
	FROM _import_serena.rnf_choi
	JOIN _import_serena.rnf_obse ON rnf_choi.choi_id = rnf_obse.obse_sex_choi_id
UNION
SELECT DISTINCT choi_list_id, 'stade' as type_liste
	FROM _import_serena.rnf_choi
	JOIN _import_serena.rnf_obse ON rnf_choi.choi_id = rnf_obse.obse_stade_choi_id
UNION
SELECT DISTINCT choi_list_id, 'unite_age' as type_liste
	FROM _import_serena.rnf_choi
	JOIN _import_serena.rnf_obse ON rnf_choi.choi_id = rnf_obse.obse_ageunit_choi_id
UNION
SELECT DISTINCT choi_list_id, 'abondance' as type_liste
	FROM _import_serena.rnf_choi
	JOIN _import_serena.rnf_obse ON rnf_choi.choi_id = rnf_obse.obse_abond_choi_id
UNION
SELECT DISTINCT choi_list_id, 'precision_denombrement' as type_liste
	FROM _import_serena.rnf_choi
	JOIN _import_serena.rnf_obse ON rnf_choi.choi_id = rnf_obse.obse_precis_choi_id
UNION
SELECT DISTINCT choi_list_id, 'sociabilite' as type_liste
	FROM _import_serena.rnf_choi
	JOIN _import_serena.rnf_obse ON rnf_choi.choi_id = rnf_obse.obse_soci_choi_id
UNION
SELECT DISTINCT choi_list_id, 'comportement' as type_liste
	FROM _import_serena.rnf_choi
	JOIN _import_serena.rnf_obse ON rnf_choi.choi_id = rnf_obse.obse_comp_choi_id
UNION
SELECT DISTINCT choi_list_id, 'methode_obs' as type_liste
	FROM _import_serena.rnf_choi
	JOIN _import_serena.rnf_obse ON rnf_choi.choi_id = rnf_obse.obse_contact_choi_id
UNION
SELECT DISTINCT choi_list_id, 'etat_bio' as type_liste
	FROM _import_serena.rnf_choi
	JOIN _import_serena.rnf_obse ON rnf_choi.choi_id = rnf_obse.obse_contact2_choi_id
UNION
SELECT DISTINCT choi_list_id, 'activite' as type_liste
	FROM _import_serena.rnf_choi
	JOIN _import_serena.rnf_obse ON rnf_choi.choi_id = rnf_obse.obse_activ_choi_id
UNION
SELECT DISTINCT choi_list_id, 'reproduction' as type_liste
	FROM _import_serena.rnf_choi
	JOIN _import_serena.rnf_obse ON rnf_choi.choi_id = rnf_obse.obse_caract_choi_id
UNION
SELECT DISTINCT choi_list_id, 'etat_sante' as type_liste
	FROM _import_serena.rnf_choi
	JOIN _import_serena.rnf_obse ON rnf_choi.choi_id = rnf_obse.obse_etat_choi_id
UNION
SELECT DISTINCT choi_list_id, 'derangement_observe' as type_liste
	FROM _import_serena.rnf_choi
	JOIN _import_serena.rnf_obse ON rnf_choi.choi_id = rnf_obse.obse_derango_choi_id
UNION
SELECT DISTINCT choi_list_id, 'derangement_intensite' as type_liste
	FROM _import_serena.rnf_choi
	JOIN _import_serena.rnf_obse ON rnf_choi.choi_id = rnf_obse.obse_derangi_choi_id
ORDER BY type_liste, choi_list_id)


SELECT DISTINCT t1.choi_id, t1.choi_nom, t1.choi_cach, t2.type_liste, t1.choi_list_id, t1.choi_abbr, t1.choi_detail, t1.choi_fact, t1.choi_sequ_l, t1.choi_prog, t1.choi_comment
FROM _import_serena.rnf_choi t1
JOIN choi_list t2 ON t1.choi_list_id= t2.choi_list_id
ORDER BY choi_id
;