-- occtax_flore.sql


-- VM
CREATE MATERIALIZED VIEW v1_compat.vm_t_fiches_cflore AS
WITH temp AS (
SELECT  max(id_releve_occtax) AS max_id
 FROM pr_occtax.t_releves_occtax
)
SELECT 
temp.max_id + id_cflore AS id_cflore , 
insee, dateobs, 
altitude_saisie, 
altitude_sig, 
altitude_retenue, 
date_insert, 
date_update, 
supprime, 
pdop, 
saisie_initiale, 
id_organisme, 
srid_dessin, 
id_protocole, 
id_lot, 
the_geom_3857, 
the_geom_local
FROM v1_compat.t_fiches_cflore, temp;
;

CREATE MATERIALIZED VIEW v1_compat.vm_cor_role_fiche_flore AS
WITH temp AS (
SELECT  max(id_releve_occtax) AS max_id
 FROM pr_occtax.t_releves_occtax
)
SELECT 
temp.max_id + id_cflore AS id_cflore,
id_role
FROM v1_compat.cor_role_fiche_cflore, temp;


CREATE MATERIALIZED VIEW v1_compat.vm_t_releves_cflore AS
WITH temp AS (
SELECT  max(id_occurrence_occtax) AS max_id
 FROM pr_occtax.t_occurrences_occtax
),
temp2 AS (
SELECT max(id_releve_occtax) AS max_id
 FROM pr_occtax.t_releves_occtax        
)
SELECT 
temp.max_id + id_releve_cflore AS id_releve_cflore, 
temp2.max_id + id_cflore AS id_cflore, 
id_nom, 
id_abondance_cflore, 
id_phenologie_cflore, 
cd_ref_origine, 
nom_taxon_saisi, 
commentaire, 
determinateur, 
supprime, 
herbier, 
gid, 
validite_cflore, 
diffusable
FROM v1_compat.t_releves_cflore, temp, temp2;


-- releve
INSERT INTO pr_occtax.t_releves_occtax(
            id_releve_occtax,
            unique_id_sinp_grp,
            id_dataset, 
            -- technique d'obs non traité en l'état -> NSP
            id_nomenclature_tech_collect_campanule, 
            id_nomenclature_grp_typ, 
            date_min, 
            date_max, 
            altitude_min, 
            altitude_max, 
            meta_device_entry, 
            geom_local, 
            geom_4326, 
            "precision",
	    comment
        )
SELECT 
    id_cflore AS id_releve_occtax,
    uuid_generate_v4() AS unique_id_sinp_grp,
    1 AS id_dataset,
    ref_nomenclatures.get_id_nomenclature('TECHNIQUE_OBS','133') AS id_nomenclature_tech_collect_campanule,
    ref_nomenclatures.get_id_nomenclature('TYP_GRP','NSP') ,
    dateobs AS date_min,
    dateobs AS date_max,
    altitude_retenue AS altitude_min,
    altitude_retenue AS altitude_max,
    saisie_initiale AS meta_device_entry, 
    ST_TRANSFORM(the_geom_local, 2972) AS geom_local,
    ST_TRANSFORM(the_geom_local, 4326) AS geom_4326,
    50 AS precision,
    'Données saisies dans Contact Flore de GeoNature 1.9'
FROM v1_compat.vm_t_fiches_cflore cf
WHERE id_cflore not in (select id_cflore from v1_compat.vm_cor_role_fiche_flore where id_role = 1)
;

-- occurrences

INSERT INTO pr_occtax.t_occurrences_occtax(
            id_occurrence_occtax,
            unique_id_occurence_occtax, 
            id_releve_occtax, 
            id_nomenclature_obs_technique, 
            id_nomenclature_bio_condition, 
            id_nomenclature_bio_status, 
            id_nomenclature_naturalness, 
            id_nomenclature_exist_proof, 
            id_nomenclature_diffusion_level, 
            id_nomenclature_observation_status, 
            id_nomenclature_blurring, 
            id_nomenclature_source_status, 
            determiner, 
            id_nomenclature_determination_method, 
            cd_nom, 
            nom_cite, 
            meta_v_taxref, 
            sample_number_proof, 
            digital_proof, 
            non_digital_proof, 
            comment
        )
    SELECT
    id_releve_cflore AS id_occurrence_occtax,
    uuid_generate_v4() AS unique_id_occurence_occtax,
    id_cflore AS id_releve_occtax,
    -- method_obs = vu
    ref_nomenclatures.get_id_nomenclature('METH_OBS','0') AS id_nomenclature_obs_technique,
    -- etat bio : non renseigné 
    ref_nomenclatures.get_id_nomenclature('ETA_BIO','1') AS id_nomenclature_bio_condition,
    -- statut bio: non renseigné
    ref_nomenclatures.get_id_nomenclature('STATUT_BIO','1') AS id_nomenclature_bio_status,
    -- naturalité: sauvage
    ref_nomenclatures.get_id_nomenclature('NATURALITE','1') AS id_nomenclature_naturalness,
    -- preuve existance: non -- TODO: si presence d'herbier à modifier
    ref_nomenclatures.get_id_nomenclature('PREUVE_EXIST','2') AS id_nomenclature_exist_proof,
    -- prevision diffusion = precise
    CASE 
      WHEN cflore.diffusable = true THEN ref_nomenclatures.get_id_nomenclature('NIV_PRECIS','5') 
      WHEN cflore.diffusable = false THEN ref_nomenclatures.get_id_nomenclature('NIV_PRECIS','4') 
      ELSE ref_nomenclatures.get_id_nomenclature('NIV_PRECIS','5') 
    END AS id_nomenclature_diffusion_level,
    -- statut obs: present
    ref_nomenclatures.get_id_nomenclature('STATUT_OBS','Pr') AS id_nomenclature_observation_status,
    -- floutage: non
    ref_nomenclatures.get_id_nomenclature('DEE_FLOU','NON') AS id_nomenclature_blurring,
    -- source: terrain
    ref_nomenclatures.get_id_nomenclature('STATUT_SOURCE','Te') AS id_nomenclature_source_status,
    -- determination = Non renseigné
    NULL AS determiner,
    -- méthode determination: non renseigné
    ref_nomenclatures.get_id_nomenclature('METH_DETERMIN','1') AS id_nomenclature_source_status,
    bib_noms.cd_nom AS cd_nom,
    nom_taxon_saisi AS nom_cite,
    'Taxref V11.0' AS meta_v_taxref,
    NULL AS sample_number_proof,
    NULL AS digital_proof, 
    NULL AS non_digital_proof,
    cflore.commentaire AS comment
    FROM v1_compat.vm_t_releves_cflore cflore
    LEFT JOIN taxonomie.bib_noms bib_noms ON bib_noms.id_nom = cflore.id_nom
WHERE id_cflore not in (select id_cflore from v1_compat.vm_cor_role_fiche_flore where id_role = 1)
;


-- counting

INSERT INTO pr_occtax.cor_counting_occtax(
            unique_id_sinp_occtax, 
            id_occurrence_occtax, 
            id_nomenclature_life_stage, 
            id_nomenclature_sex, 
            id_nomenclature_obj_count, 
            id_nomenclature_type_count, 
            count_min, 
            count_max
        )
SELECT 
uuid_generate_v4() AS unique_id_sinp_occtax,
id_releve_cflore AS id_occurrence_occtax,
CASE cflore.id_abondance_cflore
  WHEN 4 THEN ref_nomenclatures.get_id_nomenclature('STADE_VIE', '2')
  WHEN 2 THEN ref_nomenclatures.get_id_nomenclature('STADE_VIE', '25')
  WHEN 5 THEN ref_nomenclatures.get_id_nomenclature('STADE_VIE', '19')
  WHEN 1 THEN ref_nomenclatures.get_id_nomenclature('STADE_VIE', '18')
  WHEN 6 THEN ref_nomenclatures.get_id_nomenclature('STADE_VIE', '20')
  WHEN 7 THEN ref_nomenclatures.get_id_nomenclature('STADE_VIE', '0')
  WHEN 8 THEN ref_nomenclatures.get_id_nomenclature('STADE_VIE', '1')
  WHEN 3 THEN ref_nomenclatures.get_id_nomenclature('STADE_VIE', '5')
END AS id_nomenclature_life_stage,
ref_nomenclatures.get_id_nomenclature('SEXE', '0'),
-- TODO objet dénombrement: NSP (touffe, tige, hampe florale ?? ou individu)
ref_nomenclatures.get_id_nomenclature('OBJ_DENBR', 'NSP'),
CASE bib_ab.nom_abondance_cflore
WHEN '1 individu' THEN ref_nomenclatures.get_id_nomenclature('TYP_DENBR', 'Co')
ELSE ref_nomenclatures.get_id_nomenclature('TYP_DENBR', 'Es')
END AS id_nomenclature_type_count,
CASE bib_ab.nom_abondance_cflore
  WHEN '1 individu' THEN 1 
  WHEN 'De 1 à 10 individus' THEN 1
  WHEN 'De 10 à 100 individus' THEN 10
  WHEN 'Plus de 100 individus' THEN 100
END AS count_min,
-- TODO: plus de 100 individu ?
CASE bib_ab.nom_abondance_cflore
WHEN '1 individu' THEN 1 
WHEN 'De 1 à 10 individus' THEN 10
WHEN 'De 10 à 100 individus' THEN 100
WHEN 'Plus de 100 individus' THEN 100
END AS count_max
FROM v1_compat.vm_t_releves_cflore cflore
JOIN v1_compat.bib_abondances_cflore bib_ab ON bib_ab.id_abondance_cflore = cflore.id_abondance_cflore
WHERE id_releve_cflore in (select id_occurrence_occtax from pr_occtax.t_occurrences_occtax)
;

-- observateurs

INSERT INTO pr_occtax.cor_role_releves_occtax
SELECT 
uuid_generate_v4() AS unique_id_cor_role_releve,
id_cflore AS id_releve_occtax,
id_role AS id_role
FROM v1_compat.vm_cor_role_fiche_flore
WHERE id_role <> 1;

-- MAJ des observateurs dans le champ observers_txt
UPDATE pr_occtax.t_releves_occtax
SET observers_txt = observateurs
FROM (SELECT id_releve_occtax, String_AGG(prenom_role ||' ' || nom_role, ', ') as observateurs
	FROM pr_occtax.cor_role_releves_occtax inner join utilisateurs.t_roles 
		ON cor_role_releves_occtax.id_role = t_roles.id_role
	GROUP BY id_releve_occtax) As ssrqt
WHERE t_releves_occtax.id_releve_occtax = ssrqt.id_releve_occtax;

--- remplissage des cd_noms vides si nom latin
UPDATE pr_occtax.t_occurrences_occtax
	SET cd_nom = taxref.cd_nom
	FROM taxonomie.taxref
	WHERE t_occurrences_occtax.nom_cite = taxref.lb_nom AND t_occurrences_occtax.cd_nom is null;


-- Check-up des cd_nom vides
SELECT nom_cite, t_occurrences_occtax.cd_nom occtax_cd_nom, bib_noms.cd_nom taxref_cd_nom
 		FROM pr_occtax.t_occurrences_occtax LEFT JOIN taxonomie.bib_noms
 		ON t_occurrences_occtax.nom_cite = bib_noms.nom_francais
		Where t_occurrences_occtax.cd_nom is null
 		ORDER BY taxref_cd_nom,nom_cite ;

