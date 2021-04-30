Vérifier que les données contact faune et flore (source 1 et 7)
sont présentes en synthese (de part occtax)
et qu'il faut bien les supprimer de l'insert de v1_compat.syntheseff vers gn_synthese.synthese  

#---------------------------------------- Données de base

- [x] base avec le bon srid (pag/config/settings.ini)
- [ ] données ref_geo
	- [x] commune, limites de parc
	- [ ] mnt

#---------------------------------------- Migration 


- [x] User
	- [x] Ajout de users nécessaire à l'intégration des données contactFaune
	- [x] Tri des users + des groupes
	- [ ] Création de listes (t_listes) ?? utilité? 
	

- [x] Taxonomie 
	- [x] voir à passer en 14 avant prod ==> à l'installation 
		- [!!] modifier install_db avec array=( TAXREF_v14_2020.zip ESPECES_REGLEMENTEES_v11.zip LR_FRANCE_20160000.zip BDC-Statuts-v14.zip )
		- [x] !!! gros problème avec bib_nom incomplet ?? -> occurences sans cd_nom ==> résolu dans les scripts d'import
	- [x] taxons exotiques
	- [x] bib_nom : clarifier le check_cdref et find_cd_ref(cd_nom) utilisé en find_cd_ref(cd_ref)
	- [x] bib_listes: nécessite "code_liste" unique ==> référence à quoi ? ==> solution temporaire: code_liste = id_liste
		- [x] a minima: 100;"OCCTAX";"Saisie Occtax";"Liste des noms dont la saisie est proposée dans le module Occtax";"images/pictos/nopicto.gif";"";""
	- [x] taxons changés = apposer le cd_nom qui va bien
		- [x] 441839;"Évêque bleu-noir ";"Cyanocompsa cyanoides" ==> Cyanocompsa cyanoides = cd_nom:828942, cd_ref: 828943 (alors que le cd_nom 41839 pointe vers une espèce européenne)
		- [x] 765714;"";"Combretum laxum" ==> nom_complet = "Combretum laxum Aubl." ==> cd_nom : 632627, cd_ref = 629395
	- [x] cor_nom_liste entièrement refait.
- [.] Habitats ==> on verra plus tard.....

- [x] metadonnées
	- [x] Corriger/rassembler JDD dans cadres d'acquisition
	- [x] Duplication des datasets pour les années de suivi IKA et STOC (dates min/max selon synthese).
	- [x] Répercuter modifs dans t_sources
	- [x] cor_acquisition_framework_actor >> contact principal (358)
	- [x] cor_dataset_actor	>> fournisseur de la donnée (362)
	- [x] Lien dataset/module >> tout sur la synthese, datasets "saisie" dans occtax et 

- [x] gestion synonymes
	- [x] Ai regénéré la totalité de cor_synthese_v1_to_v2 ==> l'ensemble des autres questions soivent y être soldées, non?
	- [ ] fonction pour verifier la cohérence (pas de plante larve)??? 
	- [x] champ par defaut ==> ETAT_BIO
		- [x] sauf data synthèse sur pêche et chasse (rqt de MAJ)
	- [x] types
		- [x] TYP_GRP 'OBS' pour tous les lot ??==> historique selon cor_synthesev1_to_v2. Par défaut en saisie: OBS
		- [x] METH_OBS ==> historique selon cor_synthesev1_to_v2. Par défaut en saisie: VU (0)

- [x] occtax 
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
	- [x] données ex-ContactFaune dans la Synthese (manquantes dans occTax)... 
		- [x] releve
		- [x] occurences
		- [x] counting
		- [x] user


- [x] synthese
	- [x] prise en charge de l'id_critere_synthese
	- [x] MAJ des id_source et id_dataset des données annualisées IKA et STOC, etc ==> correction_data.sql

- [x] Validation

- [ ] Permissions
	- [x] Gestion de gn_permissions : 
		- [x] CRUVED: 1 à 6: Create / Read / Update / Validate / Export / Delete (dans t_actions)
		- [x] filtré par :
				- [x] SCOPE (portée): 1 aucune/ 2 Mes données / 3 Les données de mon organisme / 4 Toutes les données
				- [ ] Sensibilité
				- [ ] Geographie (non utilisé)
				- [ ] Taxo
		- [x] par module: 0	"GEONATURE"/ 1	"ADMIN" / 2	"METADATA"
		- [x] par groupe (7 à 11) 
	- [ ] Possibilité de cumuler des filtres?
	
# Atlas
- [ ] schema
- [ ] virer medias GN
- [ ] test update


#---------------------------------------- Checkup données
-[x] Synthese
	- [x] SELECT * FROM gn_synthese.synthese WHERE id_source is null; ==> résolu 
	- [x] SELECT id_module, id_dataset, count(*) FROM gn_synthese.synthese GROUP BY id_module, id_dataset ORDER BY id_module, id_dataset; ==> résolu 
	- [x] SELECT * FROM gn_synthese.synthese WHERE cd_nom is null; ==> ok

#-- Check-up corresp framework-datasets
SELECT t_acquisition_frameworks.id_acquisition_framework, acquisition_framework_name, acquisition_framework_desc,
	id_dataset, dataset_name, dataset_shortname, dataset_desc
FROM gn_meta.t_acquisition_frameworks LEFT JOIN gn_meta.t_datasets ON t_acquisition_frameworks.id_acquisition_framework = t_datasets.id_acquisition_framework
ORDER BY t_acquisition_frameworks.id_acquisition_framework, dataset_name;

#-- dans un sens....
SELECT t_acquisition_frameworks.id_acquisition_framework, acquisition_framework_name, acquisition_framework_desc, 
		synthese.id_dataset, dataset_name, dataset_shortname, dataset_desc,
		t_sources.id_source, name_source, desc_source, count(synthese.id_source)		
	FROM gn_synthese.t_sources LEFT JOIN gn_synthese.synthese ON t_sources.id_source = synthese.id_source
		LEFT JOIN gn_meta.t_datasets ON synthese.id_dataset = t_datasets.id_dataset
		LEFT JOIN gn_meta.t_acquisition_frameworks ON  t_datasets.id_acquisition_framework =t_acquisition_frameworks.id_acquisition_framework
	GROUP BY t_sources.id_source, name_source, desc_source, synthese.id_dataset, dataset_name, dataset_shortname, dataset_desc,
		t_acquisition_frameworks.id_acquisition_framework, acquisition_framework_name, acquisition_framework_desc
	ORDER BY t_acquisition_frameworks.id_acquisition_framework, dataset_name;
#--... ou dans l'autre
SELECT t_acquisition_frameworks.id_acquisition_framework, acquisition_framework_name, acquisition_framework_desc, 
		t_datasets.id_dataset, dataset_name, dataset_shortname, dataset_desc,
		t_sources.id_source, name_source, desc_source, count(synthese.id_source)		
	FROM gn_synthese.t_sources right JOIN gn_synthese.synthese ON t_sources.id_source = synthese.id_source
		right JOIN gn_meta.t_datasets ON synthese.id_dataset = t_datasets.id_dataset
		right JOIN gn_meta.t_acquisition_frameworks ON  t_datasets.id_acquisition_framework =t_acquisition_frameworks.id_acquisition_framework
	GROUP BY t_sources.id_source, name_source, desc_source, t_datasets.id_dataset, dataset_name, dataset_shortname, dataset_desc,
		t_acquisition_frameworks.id_acquisition_framework, acquisition_framework_name, acquisition_framework_desc
	ORDER BY t_acquisition_frameworks.id_acquisition_framework, t_datasets.id_dataset;
	
#---Check-up id_critere_synthese
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
