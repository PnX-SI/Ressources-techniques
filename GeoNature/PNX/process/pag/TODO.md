Vérifier que les données contact faune et flore (source 1 et 7)
sont présentes en synthese (de part occtax)
et qu'il faut bien les supprimer de l'insert de v1_compat.syntheseff vers gn_synthese.synthese  

# Données de base

- [x] base avec le bon srid (pag/config/settings.ini)
- [ ] données ref_geo
  - [ ] commune, limites de parc
  - [ ] mnt

# Migration 

- [x] !!! gros problème avec bib_nom incomplet ?? -> occurences sans cd_nom ==> résolu dans les scripts d'import

- [x] user
  - [x] Ajout de users nécessaire à l'intégration des données contactFaune

- [ ] Taxonomie 
  - [ ] bib_nom : clarifier le check_cdref et find_cd_ref(cd_nom) utilisé en find_cd_ref(cd_ref) 
  - [ ] voir à passer en 14 avant prod
  - [x] taxons exotique
  - [x] taxons changés trouver le cd_nom qui va bien
    - [x] 441839;"Évêque bleu-noir ";"Cyanocompsa cyanoides" ==> Cyanocompsa cyanoides = cd_nom:828942, cd_ref: 828943 (alors que le cd_nom 41839 pointe vers une espèce européenne)
    - [x] 765714;"";"Combretum laxum" ==> nom_complet = "Combretum laxum Aubl." ==> cd_nom : 632627, cd_ref = 629395

- [x] metadonnées
  - [x] Corriger/rassembler JDD dans cadres d'acquisition
  - [x] Duplication des datasets pour les années de suivi IKA et STOC
  - [x] Répercuter modifs dans t_sources
  - [ ] Lien avec structures productrices!??

- [ ] gestion synonymes -- ai pas réussi à 
  - [x] Ai regénéré la totalité de cor_synthese_v1_to_v2 ==> l'ensemble des autres questions soivent y être soldées, non?
  - [ ] fonction pour verifier la cohérence (pas de plante larve)??? 
  - [ ] champ par defaut ==> ETAT_BIO
    - [x] sauf data synthèse sur pêche et chasse (rqt de MAJ)
  - [ ] types
    - [ ] TYP_GRP 'OBS' pour tous les lot ??==> historique selon cor_synthesev1_to_v2. Par défaut en saisie: OBS
    - [ ] METH_OBS ==> historique selon cor_synthesev1_to_v2. Par défaut en saisie: VU (0)

- [ ] occtax 
  - [x] données faune
    - [x] releve
    - [x] occurences
    - [x] counting
    - [x] user
  - [x] données flore
    - [x] releve
    - [x] occurences
    - [x] counting
    - [x] user
  - [x] cf. Synthese car données manquantes dans occTax (données ex-ContactFaune)... 
    - [x] releve
    - [x] occurences
    - [ ] counting ==> prise en charge de l'id_critere_synthese ? (vraiment du mal avec ce COALESCE(id_critere_synthese)...)
    - [x] user


- [x] synthese
    - [ ] prise en charge de l'id_critere_synthese ==> il applique les mêmes id_nomenclatures à tous les enregistrements? (vraiment du mal avec ce COALESCE(id_critere_synthese)...)
    - [x] MAJ des id_source et id_dataset des données annualisées IKA et STOC


-------------Checkup données
-[ ] Synthese
    - [ ] SELECT * FROM gn_synthese.synthese WHERE id_source is null; ==> résolu 
    - [ ] SELECT id_module, id_dataset, count(*) FROM gn_synthese.synthese GROUP BY id_module, id_dataset ORDER BY id_module, id_dataset; ==> résolu 
    - [x] SELECT * FROM gn_synthese.synthese WHERE cd_nom is null; ==> ok
    - [ ] --- USER ====> ???--- test des id_critere_synthese


-[ ] Validation

  
# Atlas

- [ ] schema
- [ ] virer medias GN
- [ ] test update


---Check-up id_critere_synthese
SELECT synthese.id_source, name_source, id_module, id_dataset, id_nomenclature_geo_object_nature, id_nomenclature_grp_typ, 
	grp_method, id_nomenclature_obs_technique, id_nomenclature_bio_status, id_nomenclature_bio_condition, 
	id_nomenclature_naturalness, id_nomenclature_exist_proof, id_nomenclature_valid_status, 
	id_nomenclature_diffusion_level, id_nomenclature_life_stage, id_nomenclature_sex, id_nomenclature_obj_count, 
	id_nomenclature_type_count, id_nomenclature_sensitivity, id_nomenclature_observation_status, 
	id_nomenclature_blurring, id_nomenclature_source_status, id_nomenclature_info_geo_type, 
	id_nomenclature_behaviour, id_nomenclature_biogeo_status 
	FROM gn_synthese.synthese inner join gn_synthese.t_sources on synthese.id_source = t_sources.id_source
	group by synthese.id_source, name_source, id_module, id_dataset, id_nomenclature_geo_object_nature, id_nomenclature_grp_typ, 
	grp_method, id_nomenclature_obs_technique, id_nomenclature_bio_status, id_nomenclature_bio_condition, 
	id_nomenclature_naturalness, id_nomenclature_exist_proof, id_nomenclature_valid_status, 
	id_nomenclature_diffusion_level, id_nomenclature_life_stage, id_nomenclature_sex, id_nomenclature_obj_count, 
	id_nomenclature_type_count, id_nomenclature_sensitivity, id_nomenclature_observation_status, 
	id_nomenclature_blurring, id_nomenclature_source_status, id_nomenclature_info_geo_type, 
	id_nomenclature_behaviour, id_nomenclature_biogeo_status
	Order by id_source, id_dataset, id_nomenclature_geo_object_nature, id_nomenclature_grp_typ, 
	grp_method, id_nomenclature_obs_technique, id_nomenclature_bio_status, id_nomenclature_bio_condition, 
	id_nomenclature_naturalness, id_nomenclature_exist_proof, id_nomenclature_valid_status, 
	id_nomenclature_diffusion_level, id_nomenclature_life_stage, id_nomenclature_sex, id_nomenclature_obj_count, 
	id_nomenclature_type_count, id_nomenclature_sensitivity, id_nomenclature_observation_status, 
	id_nomenclature_blurring, id_nomenclature_source_status, id_nomenclature_info_geo_type, 
	id_nomenclature_behaviour, id_nomenclature_biogeo_status ;
