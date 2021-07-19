--- 1/ releves; 2/ occurrences; 3/observateurs; 4/dénombrement
SELECT setval('pr_occtax.cor_counting_occtax_id_counting_occtax_seq', 1);

-- 1: releve

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
    id_cf AS id_releve_occtax,
    uuid_generate_v4() AS unique_id_sinp_grp,
    1 AS id_dataset,
    ref_nomenclatures.get_id_nomenclature('TECHNIQUE_OBS','133') AS id_nomenclature_tech_collect_campanule,
    COALESCE(v1_compat.get_synonyme_id_nomenclature('TYP_GRP', 'id_lot', id_lot), ref_nomenclatures.get_id_nomenclature('TYP_GRP','NSP')) AS id_nomenclature_grp_typ,   
dateobs AS date_min,
    dateobs AS date_max,
    altitude_retenue AS altitude_min,
    altitude_retenue AS altitude_max,
    saisie_initiale AS meta_device_entry, 
    ST_TRANSFORM(the_geom_local, :srid_local) AS geom_local,
    ST_TRANSFORM(the_geom_local, 4326) AS geom_4326,
    50 AS precision,
    'Données saisies dans Contact Vertébrés de GeoNature 1.9'
FROM v1_compat.t_fiches_cf cf
WHERE id_cf not in (select id_cf from v1_compat.cor_role_fiche_cf where id_role = 1)
;

-- 2: occurence

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
    id_releve_cf AS id_occurrence_occtax,
    uuid_generate_v4() AS unique_id_occurence_occtax,
    id_cf AS id_releve_occtax,
    COALESCE(
	v1_compat.get_synonyme_id_nomenclature('METH_OBS', 'id_critere_synthese', id_critere_cf),
	ref_nomenclatures.get_id_nomenclature('METH_OBS','21')
	) AS id_nomenclature_obs_meth,
    COALESCE(
	v1_compat.get_synonyme_id_nomenclature('ETA_BIO', 'id_critere_synthese', id_critere_cf),
	ref_nomenclatures.get_id_nomenclature('ETA_BIO','0')
	) AS id_nomenclature_bio_condition,
    COALESCE(
	v1_compat.get_synonyme_id_nomenclature('STATUT_BIO', 'id_critere_synthese', id_critere_cf),
	ref_nomenclatures.get_id_nomenclature('STATUT_BIO','1')
	) AS id_nomenclature_bio_status,
     ref_nomenclatures.get_id_nomenclature('NATURALITE','1') AS id_nomenclature_naturalness,
     ref_nomenclatures.get_id_nomenclature('PREUVE_EXIST','2') AS id_nomenclature_exist_proof,
     CASE 
       WHEN cf.diffusable = true THEN ref_nomenclatures.get_id_nomenclature('NIV_PRECIS','5') 
       WHEN cf.diffusable = false THEN ref_nomenclatures.get_id_nomenclature('NIV_PRECIS','4') 
       ELSE ref_nomenclatures.get_id_nomenclature('NIV_PRECIS','5') 
     END AS id_nomenclature_diffusion_level,
     ref_nomenclatures.get_id_nomenclature('STATUT_OBS','Pr') AS id_nomenclature_observation_status,
     ref_nomenclatures.get_id_nomenclature('DEE_FLOU','NON') AS id_nomenclature_blurring,
     ref_nomenclatures.get_id_nomenclature('STATUT_SOURCE','Te') AS id_nomenclature_source_status,
     -- determination = Non renseigné
     NULL AS determiner,
     ref_nomenclatures.get_id_nomenclature('METH_DETERMIN','1') AS id_nomenclature_source_status,
     bib_noms.cd_nom AS cd_nom,
     nom_taxon_saisi AS nom_cite,
     'Taxref V11.0' AS meta_v_taxref,
     NULL AS sample_number_proof,
     NULL AS digital_proof, 
     NULL AS non_digital_proof,
     cf.commentaire AS comment
    FROM v1_compat.t_releves_cf cf
    LEFT JOIN taxonomie.bib_noms bib_noms ON bib_noms.id_nom = cf.id_nom
WHERE id_cf not in (select id_cf from v1_compat.cor_role_fiche_cf where id_role = 1)
;
--- remplissage des cd_noms vides si nom latin
UPDATE pr_occtax.t_occurrences_occtax
	SET cd_nom = taxref.cd_nom
	FROM taxonomie.taxref
	WHERE t_occurrences_occtax.nom_cite = taxref.lb_nom AND t_occurrences_occtax.cd_nom is null;
--- correction de noms cites et cd_nom correspondants
UPDATE pr_occtax.t_occurrences_occtax
	SET nom_cite = 'Dacnis bleu', cd_nom = 441849 WHERE nom_cite = 'Dacnis bleu ';
UPDATE pr_occtax.t_occurrences_occtax
	SET nom_cite = 'Tangara des palmiers', cd_nom = 828962 WHERE nom_cite = 'Tangara des palmiers ';
UPDATE pr_occtax.t_occurrences_occtax
	SET nom_cite = 'Tangara évêque', cd_nom = 886020 WHERE nom_cite = 'Tangara évêque ';

-- 3: observateurs
INSERT INTO pr_occtax.cor_role_releves_occtax
	SELECT 
	uuid_generate_v4() AS unique_id_cor_role_releve,
	id_cf AS id_releve_occtax,
	id_role AS id_role
	FROM v1_compat.cor_role_fiche_cf
	WHERE id_role <> 1;
-- MAJ des observateurs dans le champ observers_txt
--UPDATE pr_occtax.t_releves_occtax
--	SET observers_txt = observateurs
--	FROM (SELECT id_releve_occtax, String_AGG(prenom_role ||' ' || nom_role, ', ') as observateurs
--		FROM pr_occtax.cor_role_releves_occtax inner join utilisateurs.t_roles 
--			ON cor_role_releves_occtax.id_role = t_roles.id_role
--		GROUP BY id_releve_occtax) As ssrqt
--	WHERE t_releves_occtax.id_releve_occtax = ssrqt.id_releve_occtax;


-- 4: denombrement
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

-- adulte male
SELECT 
uuid_generate_v4() AS unique_id_sinp_occtax,
id_releve_cf AS id_occurrence_occtax,
ref_nomenclatures.get_id_nomenclature('STADE_VIE', '2'),
ref_nomenclatures.get_id_nomenclature('SEXE', '3'),
ref_nomenclatures.get_id_nomenclature('OBJ_DENBR', 'IND'),
ref_nomenclatures.get_id_nomenclature('TYP_DENBR', 'NSP'),
am AS count_min,
am AS count_max
FROM v1_compat.t_releves_cf cf
WHERE am > 0 and id_releve_cf in (select id_occurrence_occtax from pr_occtax.t_occurrences_occtax)

UNION
-- adulte femelle
SELECT 
uuid_generate_v4() AS unique_id_sinp_occtax,
id_releve_cf AS id_occurrence_occtax,
ref_nomenclatures.get_id_nomenclature('STADE_VIE', '2'),
ref_nomenclatures.get_id_nomenclature('SEXE', '2'),
ref_nomenclatures.get_id_nomenclature('OBJ_DENBR', 'IND'),
ref_nomenclatures.get_id_nomenclature('TYP_DENBR', 'NSP'),
af AS count_min,
af AS count_max
FROM v1_compat.t_releves_cf cf
WHERE af > 0 and id_releve_cf in (select id_occurrence_occtax from pr_occtax.t_occurrences_occtax)

UNION
-- adulte indetermine
SELECT 
uuid_generate_v4() AS unique_id_sinp_occtax,
id_releve_cf AS id_occurrence_occtax,
ref_nomenclatures.get_id_nomenclature('STADE_VIE', '2'),
ref_nomenclatures.get_id_nomenclature('SEXE', '0'),
ref_nomenclatures.get_id_nomenclature('OBJ_DENBR', 'IND'),
ref_nomenclatures.get_id_nomenclature('TYP_DENBR', 'NSP'),
ai AS count_min,
ai AS count_max
FROM v1_compat.t_releves_cf cf
WHERE ai > 0  and id_releve_cf in (select id_occurrence_occtax from pr_occtax.t_occurrences_occtax)

UNION
-- sexe et age indeterminé
SELECT 
uuid_generate_v4() AS unique_id_sinp_occtax,
id_releve_cf AS id_occurrence_occtax,
ref_nomenclatures.get_id_nomenclature('STADE_VIE', '0'),
ref_nomenclatures.get_id_nomenclature('SEXE', '0'),
ref_nomenclatures.get_id_nomenclature('OBJ_DENBR', 'IND'),
ref_nomenclatures.get_id_nomenclature('TYP_DENBR', 'NSP'),
sai AS count_min,
sai AS count_max
FROM v1_compat.t_releves_cf cf
WHERE sai > 0 and id_releve_cf in (select id_occurrence_occtax from pr_occtax.t_occurrences_occtax)

UNION
-- non adulte
SELECT 
uuid_generate_v4() AS unique_id_sinp_occtax,
id_releve_cf AS id_occurrence_occtax,
ref_nomenclatures.get_id_nomenclature('STADE_VIE', '3'),
ref_nomenclatures.get_id_nomenclature('SEXE', '0'),
ref_nomenclatures.get_id_nomenclature('OBJ_DENBR', 'IND'),
ref_nomenclatures.get_id_nomenclature('TYP_DENBR', 'NSP'),
na AS count_min,
na AS count_max
FROM v1_compat.t_releves_cf cf
WHERE na > 0 and id_releve_cf in (select id_occurrence_occtax from pr_occtax.t_occurrences_occtax)

UNION
-- jeune
SELECT 
uuid_generate_v4() AS unique_id_sinp_occtax,
id_releve_cf AS id_occurrence_occtax,
ref_nomenclatures.get_id_nomenclature('STADE_VIE', '3'),
ref_nomenclatures.get_id_nomenclature('SEXE', '0'),
ref_nomenclatures.get_id_nomenclature('OBJ_DENBR', 'IND'),
ref_nomenclatures.get_id_nomenclature('TYP_DENBR', 'NSP'),
jeune AS count_min,
jeune AS count_max
FROM v1_compat.t_releves_cf cf
WHERE jeune > 0 and id_releve_cf in (select id_occurrence_occtax from pr_occtax.t_occurrences_occtax)

UNION
-- yearling
SELECT 
uuid_generate_v4() AS unique_id_sinp_occtax,
id_releve_cf AS id_occurrence_occtax,
ref_nomenclatures.get_id_nomenclature('STADE_VIE', '4'),
ref_nomenclatures.get_id_nomenclature('SEXE', '0'),
ref_nomenclatures.get_id_nomenclature('OBJ_DENBR', 'IND'),
ref_nomenclatures.get_id_nomenclature('TYP_DENBR', 'NSP'),
yearling AS count_min,
yearling AS count_max
FROM v1_compat.t_releves_cf cf
WHERE yearling > 0 and id_releve_cf in (select id_occurrence_occtax from pr_occtax.t_occurrences_occtax)
;



------------Ajout des refs dae la synthese qui n'existent pas dans contact faune (ancien outil)
-------------------- D'abord: insérer les données historiques de "Contact Faune" dans OccTax: where id_source = 1 and id_fiche_source is null;
--- 1:  les releves
INSERT INTO pr_occtax.t_releves_occtax(
            id_releve_occtax,
            unique_id_sinp_grp,
            id_dataset, 
	   observers_txt,
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
	    comment)
SELECT 
        (id_synthese-70770) AS id_releve_occtax,
	uuid_generate_v4() AS unique_id_sinp_grp,
	1 AS id_dataset,
	null as observers_txt,
	ref_nomenclatures.get_id_nomenclature('TECHNIQUE_OBS','133') AS id_nomenclature_tech_collect_campanule,
    	COALESCE(v1_compat.get_synonyme_id_nomenclature('TYP_GRP', 'id_lot', id_lot), ref_nomenclatures.get_id_nomenclature('TYP_GRP','NSP')) AS id_nomenclature_grp_typ,   
	dateobs AS date_min,
   	dateobs AS date_max,
    	altitude_retenue AS altitude_min,
    	altitude_retenue AS altitude_max,
    	'web' AS meta_device_entry, 
    	ST_TRANSFORM(the_geom_local, 2972) AS geom_local,
    	ST_TRANSFORM(the_geom_local, 4326) AS geom_4326,
    	50 as precision,
    'Données saisies dans l''outil ContactFaune.'
FROM v1_compat.syntheseff
WHERE id_source = 1 and id_fiche_source is null
GROUP BY id_synthese,   
	dateobs,
	observateurs,
    	altitude_retenue,
    	the_geom_local, id_lot
order by id_synthese;

--- 2: les occurences

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
    (id_synthese-70590) AS id_occurrence_occtax,
    uuid_generate_v4() AS unique_id_occurence_occtax,
    (id_synthese-70770) AS id_releve_occtax,
    COALESCE(
	v1_compat.get_synonyme_id_nomenclature('METH_OBS', 'id_critere_synthese', id_critere_synthese),
	ref_nomenclatures.get_id_nomenclature('METH_OBS','21')
	) AS id_nomenclature_obs_meth,
    COALESCE(
	v1_compat.get_synonyme_id_nomenclature('ETA_BIO', 'id_critere_synthese', id_critere_synthese),
	ref_nomenclatures.get_id_nomenclature('ETA_BIO','0')
	) AS id_nomenclature_bio_condition,
    COALESCE(
	v1_compat.get_synonyme_id_nomenclature('STATUT_BIO', 'id_critere_synthese', id_critere_synthese),
	ref_nomenclatures.get_id_nomenclature('STATUT_BIO','1')
	) AS id_nomenclature_bio_status,
     ref_nomenclatures.get_id_nomenclature('NATURALITE','1') AS id_nomenclature_naturalness,
     ref_nomenclatures.get_id_nomenclature('PREUVE_EXIST','2') AS id_nomenclature_exist_proof,
     ref_nomenclatures.get_id_nomenclature('NIV_PRECIS','5') AS id_nomenclature_diffusion_level,
     ref_nomenclatures.get_id_nomenclature('STATUT_OBS','Pr') AS id_nomenclature_observation_status,
     ref_nomenclatures.get_id_nomenclature('DEE_FLOU','NON') AS id_nomenclature_blurring,
     ref_nomenclatures.get_id_nomenclature('STATUT_SOURCE','Te') AS id_nomenclature_source_status,
     -- determination = Non renseigné
     determinateur AS determiner,
     ref_nomenclatures.get_id_nomenclature('METH_DETERMIN','1') AS id_nomenclature_source_status,
     syntheseff.cd_nom AS cd_nom,
     lb_nom AS nom_cite,
     'Taxref V11.0' AS meta_v_taxref,
     NULL AS sample_number_proof,
     NULL AS digital_proof, 
     NULL AS non_digital_proof,
     remarques AS comment
	FROM v1_compat.syntheseff
		inner join taxonomie.taxref on syntheseff.cd_nom = taxref.cd_nom
	WHERE id_source = 1 and id_fiche_source is null and syntheseff.cd_nom <> 441839 
	ORDER BY id_synthese;

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
    (id_synthese-70590) AS id_occurrence_occtax,
    uuid_generate_v4() AS unique_id_occurence_occtax,
    (id_synthese-70770) AS id_releve_occtax,
    COALESCE(
	v1_compat.get_synonyme_id_nomenclature('METH_OBS', 'id_critere_synthese', id_critere_synthese),
	ref_nomenclatures.get_id_nomenclature('METH_OBS','21')
	) AS id_nomenclature_obs_meth,
    COALESCE(
	v1_compat.get_synonyme_id_nomenclature('ETA_BIO', 'id_critere_synthese', id_critere_synthese),
	ref_nomenclatures.get_id_nomenclature('ETA_BIO','0')
	) AS id_nomenclature_bio_condition,
    COALESCE(
	v1_compat.get_synonyme_id_nomenclature('STATUT_BIO', 'id_critere_synthese', id_critere_synthese),
	ref_nomenclatures.get_id_nomenclature('STATUT_BIO','1')
	) AS id_nomenclature_bio_status,
     ref_nomenclatures.get_id_nomenclature('NATURALITE','1') AS id_nomenclature_naturalness,
     ref_nomenclatures.get_id_nomenclature('PREUVE_EXIST','2') AS id_nomenclature_exist_proof,
     ref_nomenclatures.get_id_nomenclature('NIV_PRECIS','5') AS id_nomenclature_diffusion_level,
     ref_nomenclatures.get_id_nomenclature('STATUT_OBS','Pr') AS id_nomenclature_observation_status,
     ref_nomenclatures.get_id_nomenclature('DEE_FLOU','NON') AS id_nomenclature_blurring,
     ref_nomenclatures.get_id_nomenclature('STATUT_SOURCE','Te') AS id_nomenclature_source_status,
     -- determination = Non renseigné
     determinateur AS determiner,
     ref_nomenclatures.get_id_nomenclature('METH_DETERMIN','1') AS id_nomenclature_source_status,
     828942 AS cd_nom,
     'Cyanocompsa cyanoides' AS nom_cite,
     'Taxref V11.0' AS meta_v_taxref,
     NULL AS sample_number_proof,
     NULL AS digital_proof, 
     NULL AS non_digital_proof,
     remarques AS comment
	FROM v1_compat.syntheseff
	WHERE id_source = 1 and id_fiche_source is null and cd_nom = 441839 
	ORDER BY id_synthese;

---- 3: les observateurs:

INSERT INTO pr_occtax.cor_role_releves_occtax
SELECT 
	uuid_generate_v4() AS unique_id_cor_role_releve,
	(id_synthese-70770) AS id_releve_occtax,
	id_role AS id_role
FROM  v1_compat.syntheseff left join utilisateurs.t_roles
	ON replace(syntheseff.observateurs, 'é', 'e') ilike replace (t_roles.nom_role, 'Lenganey', 'Langaney') || ' '|| t_roles.prenom_role||'%'
	or replace(syntheseff.observateurs, 'é', 'e') ilike '%'|| replace (t_roles.nom_role, 'Lenganey', 'Langaney')  || ' '|| t_roles.prenom_role
	or replace(syntheseff.observateurs, 'é', 'e') ilike '%'|| replace (t_roles.nom_role, 'Lenganey', 'Langaney')  || ' '|| t_roles.prenom_role||'%'
WHERE id_source = 1 and id_fiche_source is null and id_role is not null
ORDER BY id_synthese, id_role;

----4 :  les denombrements

INSERT INTO pr_occtax.cor_counting_occtax(
            unique_id_sinp_occtax, 
            id_occurrence_occtax, 
            id_nomenclature_life_stage, 
            id_nomenclature_sex, 
            id_nomenclature_obj_count, 
            id_nomenclature_type_count, 
            count_min, 
            count_max)
SELECT uuid_generate_v4() AS unique_id_sinp_occtax,
	    (id_synthese-70590) AS id_occurrence_occtax,
	    ref_nomenclatures.get_id_nomenclature('STADE_VIE', '0'),
	    ref_nomenclatures.get_id_nomenclature('SEXE', '6'),
	    ref_nomenclatures.get_id_nomenclature('OBJ_DENBR', 'IND'),
	    ref_nomenclatures.get_id_nomenclature('TYP_DENBR', 'NSP'),
	    effectif_total AS count_min,
	    effectif_total AS count_max
	FROM v1_compat.syntheseff
	WHERE id_source = 1 and id_fiche_source is null 
	ORDER BY id_synthese;




--- on remet les compteurs id au max+1
SELECT setval('pr_occtax.t_releves_occtax_id_releve_occtax_seq', (SELECT MAX(id_releve_occtax) FROM pr_occtax.t_releves_occtax)+1);
SELECT setval('pr_occtax.t_occurrences_occtax_id_occurrence_occtax_seq', (SELECT MAX(id_occurrence_occtax) FROM pr_occtax.t_occurrences_occtax)+1);

-- Check-up des cd_nom vides
SELECT nom_cite, t_occurrences_occtax.cd_nom occtax_cd_nom, bib_noms.cd_nom taxref_cd_nom
 		FROM pr_occtax.t_occurrences_occtax LEFT JOIN taxonomie.bib_noms
 		ON t_occurrences_occtax.nom_cite = bib_noms.nom_francais
		Where t_occurrences_occtax.cd_nom is null
 		ORDER BY taxref_cd_nom,nom_cite ;


