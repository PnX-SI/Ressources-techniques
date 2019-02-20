-- Par Donovan Maillard (Flavia)
-- Décembre 2018 (GeoNature 2.0.0-rc.3)
-- Exemple de SQL permettant d'importer des données historiques présentes dans un tableur vers la synthèse de GeoNature

-- COTÉ SERVEUR -

	-- Importer le tableur csv (utf-8). 

		-- Se connecter avec le superutilisateur
		-- sudo su postgres
		-- psql -d mabase 

		-- Importer les données dans le schéma gn_import
		SELECT gn_imports.load_csv_file('/home/monuser/archives/imports/mabase_historique/import_mabase.csv', 'gn_imports.import_mabase');
		ALTER TABLE gn_imports.import_mabase OWNER TO monuser;

	-- Le fichier doit être correctement encodé et formaté. Passer par R si nécessaire. 
	-- Si nécessaires, quelques corrections peuvent être faites : corrections d'identifiants en doublon etc, controles de conformité etc
	-- Sont à checker : identifiant mabase en doublon (ajouter un _bis), les dates de début indiquant une période, les contenus de champs 
  -- non adaptés, etc




-- COTÉ BDD : PG ADMIN -

--Ajouter une clé primaire à la table
ALTER TABLE gn_imports.import_mabase ADD PRIMARY KEY (identifiant_mabase);


-- Rattachement des noms latins avec le taxref --
-- Forcer la mise à jour de la casse : majuscule au premier et uniquement au premier caractère du nom binomial
UPDATE gn_imports.import_mabase
SET nom_binomial= (SELECT (UPPER(LEFT(nom_binomial,1))||LOWER(substring(nom_binomial,2))))

-- Créer une table de rattachement comprenant nom et cd_nom, ainsi que le mode de rattachement
CREATE TABLE gn_imports.rattachement_mabase_taxref
	(
	nom_binomial text,
	cd_nom integer,
	rattachement text
	)

-- Renseigner la table en association un unique cd_nom à chaque nom binomial utilisé
-- Le rattachement se fait entre le nom binomial de la mabase et le nom binomial du taxref. Lorsque le nom binomial a plusieurs cd_nom dans le taxref, le dernier (le plus élevé) est conservé.
-- edit : mauvaise pratique, mieux vaut rattacher manuellement les noms binomiaux pour lesquels plusieurs cd_ref existent pour éviter les rattachements aléatoires). 
INSERT INTO gn_imports.rattachement_mabase_taxref (nom_binomial,cd_nom,rattachement)
	(
	SELECT DISTINCT (f.nom_binomial),MAX(t.cd_nom),'Automatique'
	FROM gn_imports.import_mabase f
	LEFT JOIN taxonomie.taxref t ON f.nom_binomial=t.lb_nom
	GROUP BY f.nom_binomial
	ORDER BY f.nom_binomial
	)

-- Manuellement, donner le cd_nom du genre leptidea au groupe Leptidea sp. (193993)
UPDATE gn_imports.rattachement_mabase_taxref
SET cd_nom='193993', 
	rattachement='Manuel'
WHERE nom_binomial='Leptidea sp.'

-- Préparation du mapping
SELECT gn_imports.fct_generate_matching('gn_imports.import_mabase', 'gn_synthese.synthese');
SELECT gn_imports.fct_generate_matching('gn_imports.import_mabase', 'gn_synthese.cor_observer_synthese');
 
-- Dans notre cas, generate query n'a pas été utilisé (reprendre directement le script ci-dessous. Sauvegardé en commentaire dans matching_tables

-- Préparation de la table t_sources de la synthèse
INSERT INTO gn_synthese.t_sources(name_source, desc_source)
VALUES('Historique mabase', 'Données historiques de ma structure issues de la mabase V41') returning id_source;

-- Intégration des données à la synthèse
INSERT INTO gn_synthese.synthese(
	date_min
	,id_synthese
	,id_source
	,entity_source_pk_value
	,nom_cite
	,altitude_min
	,altitude_max
	,count_max
	,count_min
	,id_nomenclature_determination_method
	,determiner
	,observers
	,id_nomenclature_obs_meth
	,id_nomenclature_life_stage
	,id_digitiser
	,comments
	,last_action
	,non_digital_proof
	,digital_proof
	,id_nomenclature_sensitivity
	,id_nomenclature_observation_status
	,id_nomenclature_blurring
	,the_geom_local
	,the_geom_point
	,the_geom_4326
	,cd_nom
	,id_nomenclature_obj_count
	,id_nomenclature_type_count
	,id_nomenclature_source_status
	,id_nomenclature_info_geo_type
	,id_nomenclature_sex
	,id_nomenclature_geo_object_nature
	,id_nomenclature_grp_typ
	,id_nomenclature_obs_technique
	,id_nomenclature_bio_status
	,id_nomenclature_bio_condition
	,id_nomenclature_naturalness
	,id_nomenclature_exist_proof
	,id_nomenclature_valid_status
	,id_nomenclature_diffusion_level
	,meta_v_taxref
	,meta_create_date
	,unique_id_sinp_grp
	,unique_id_sinp
	,meta_update_date
	,id_dataset
	,date_max
)

SELECT 
	-- Formater les dates en fonction de la précision des dates des observations
	CASE
			WHEN ( (heure_debut IS NULL OR heure_debut='' OR heure_debut='NA') 
				AND (jour_debut IS NULL OR jour_debut='' OR jour_debut='NA')
				AND (mois_debut IS NULL OR mois_debut='' OR mois_debut='NA')
				) THEN ('01/01/'||annee_debut||' 00:00:00'):: timestamp without time zone
			WHEN ( (heure_debut IS NULL OR heure_debut='') 
				AND (jour_debut IS NULL OR jour_debut='' OR jour_debut='NA')
				AND (mois_debut IS NOT NULL AND mois_debut !='' AND mois_debut !='NA')
				) THEN ('01/'||mois_debut||'/'||annee_debut||' 00:00:00')::timestamp without time zone
			WHEN ( (heure_debut IS NULL OR heure_debut='' OR heure_debut='NA') 
				AND (jour_debut IS NOT NULL AND jour_debut !='' AND jour_debut !='NA')
				AND (mois_debut IS NOT NULL AND mois_debut !='' AND mois_debut !='NA') 
				) THEN (jour_debut||'/'||mois_debut||'/'||annee_debut||' 00:00:00')::timestamp without time zone
			WHEN ( (heure_debut IS NOT NULL AND heure_debut !='' AND heure_debut !='NA')
				AND (jour_debut IS NOT NULL AND jour_debut !='' AND jour_debut !='NA')
				AND (mois_debut IS NOT NULL AND mois_debut !='' AND mois_debut !='NA')
				) THEN (jour_debut||'/'||mois_debut||'/'||annee_debut||' '||heure_debut)::timestamp without time zone
		END AS date_min

	,nextval('gn_synthese.synthese_id_synthese_seq'::regclass)::integer AS id_synthese

	,'2' AS id_source
	
	,a.identifiant_mabase::character varying AS entity_source_pk_value

	,a.nom_binomial::character varying AS nom_cite
	
	,CASE WHEN (altitude_m='NA') THEN '0'::integer
	ELSE (a.altitude_m)::integer 
	END AS altitude_min
	
	,CASE WHEN (altitude_m='NA') THEN '0'::integer
	ELSE (a.altitude_m)::integer 
	END AS altitude_max

	,CASE WHEN (nombre_total='NA') THEN '1'::integer
	ELSE (a.nombre_total)::integer 
	END AS count_min
	
	,CASE WHEN (nombre_total='NA') THEN '1'::integer
	ELSE (a.nombre_total)::integer 
	END AS count_max

	,CASE
			WHEN (methode_determination IS NULL OR methode_determination='') THEN ('446'):: integer
			WHEN (methode_determination='Examen Macroscopique' AND (nature_donnee='COLL' OR nature_donnee='Coll')) THEN ('462'):: integer 
			WHEN (methode_determination='Examen Macroscopique' AND nature_donnee='Phot') THEN ('465'):: integer 
			WHEN (methode_determination='Genitalia' AND (nature_donnee='COLL' OR nature_donnee='Coll')) THEN ('351'):: integer 
			ELSE ('352'):: integer
		END AS id_nomenclature_determination_method
	
	,a.determinateurs::character varying AS determiner
	
	,a.observateurs::character varying AS observers

	,n.id_nomenclature::integer AS id_nomenclature_obs_meth

	,CASE
			WHEN (stade='Ovo' OR stade='ovo') THEN ('10'):: integer
			WHEN (stade='Larva' OR stade='larva') THEN ('8'):: integer
			WHEN (stade='Pupa') THEN ('15'):: integer
			WHEN (stade='Imago') THEN ('16'):: integer
			ELSE ('1'):: integer
		END AS id_nomenclature_life_stage
	
	,CASE WHEN (a.auteur_saisie='' OR a.auteur_saisie IS NULL) THEN ('0')::integer
		ELSE (u.id_role)::integer 
		END AS id_digitiser	
		
	,a.notes_observations::text AS comments
	
	,'Insert'::character AS last_action
	
	,a.reference_photo_specimen::text AS non_digital_proof
	
	,'Collection : '||a.collection_personnelle::text AS digital_proof
		
	,'67'::integer AS id_nomenclature_sensitivity
	
	,'89'::integer AS id_nomenclature_observation_status
	
	,'176'::integer AS id_nomenclature_blurring
	
	,ST_SetSRID(ST_MakePoint(replace(x_m,',','.')::numeric, replace(y_m,',','.')::numeric),2154) AS the_geom_local
	
    ,ST_Transform(ST_Centroid(ST_SetSRID(ST_MakePoint(replace(x_m,',','.')::numeric, replace(y_m,',','.')::numeric),2154)),4326) AS the_geom_point
	
	,ST_Transform(ST_SetSRID(ST_MakePoint(replace(x_m,',','.')::numeric, replace(y_m,',','.')::numeric),2154),4326) AS the_geom_4326

	,r.cd_nom::integer AS cd_nom

	,CASE WHEN (origine_donnees='Ma Structure' OR origine_donnees='Tel partenaire') THEN('147')::integer 
			ELSE ('146')::integer
			END AS id_nomenclature_obj_count
	
	,'95'::integer AS id_nomenclature_type_count
	
	,CASE WHEN (nature_donnee='COLL' OR nature_donnee='Coll') THEN ('72'):: integer
			WHEN (reference_biblio_source!='' AND reference_biblio_source IS NOT NULL) THEN('73'):: integer
			ELSE ('75'):: integer
			END AS id_nomenclature_source_status
	
	,CASE WHEN (precisions_coordonnees='Pointage exact') THEN('127'):: integer
			ELSE ('128'):: integer
			END AS id_nomenclature_info_geo_type
	
	,CASE WHEN(nombre_male='NA' AND nombre_femelle='NA') THEN('172')::integer
			WHEN (nombre_male!='NA' AND nombre_femelle='NA') THEN('169')::integer
			WHEN (nombre_male='NA' AND nombre_femelle!='NA') THEN('168')::integer
			WHEN (nombre_male!='NA' AND nombre_femelle!='NA') THEN('171')::integer
			END AS id_nomenclature_sex
	
	,CASE WHEN(precisions_coordonnees='Pointage exact') THEN ('175')::integer
			ELSE ('174')::integer 
			END AS id_nomenclature_geo_object_nature
	
	,'134'::integer AS id_nomenclature_grp_typ
	
	,'317'::integer AS id_nomenclature_obs_technique
	
	,'29'::integer AS id_nomenclature_bio_status
	
	,CASE WHEN(methode_observation='Cadavre') THEN('159')::integer
			ELSE('158')::integer
			END AS id_nomenclature_bio_condition
	
	,'161'::integer AS id_nomenclature_naturalness
	
	,'81'::integer AS id_nomenclature_exist_proof
	
	,'466'::integer AS id_nomenclature_valid_status
	
	,'145'::integer AS id_nomenclature_diffusion_level
	
	,gn_commons.get_default_parameter('taxref_version'::text, NULL::integer)::character varying AS meta_v_taxref
	
	,now()::timestamp without time zone AS meta_create_date
	
	,uuid_generate_v4()::uuid AS unique_id_sinp_grp
	
	,uuid_generate_v4()::uuid AS unique_id_sinp
	
	,now()::timestamp without time zone AS meta_update_date
	
	,'6' AS id_dataset
	
	,-- Réécriture de la date de fin
		CASE
			-- si la date fin est complète, ne pas la modifier
			WHEN ( (hure_fin IS NOT NULL AND hure_fin !='' AND hure_fin !='NA') 
				AND (jour_fin IS NOT NULL AND jour_fin !='' AND jour_fin !='NA')
				AND (mois_fin IS NOT NULL AND mois_fin !='' AND mois_fin !='NA')
				AND (annee_fin IS NOT NULL OR annee_fin!='' OR mois_fin!='NA')
				) THEN (jour_fin||'/'||mois_fin||'/'||annee_fin||' '||hure_fin):: timestamp without time zone

			-- si une date fin est définie mais pas l'heure, définir 23h59m59
			WHEN ( (hure_fin IS NULL OR hure_fin='' OR hure_fin='NA') 
				AND (jour_fin IS NOT NULL AND jour_fin !='' AND jour_fin !='NA')
				AND (mois_fin IS NOT NULL AND mois_fin !='' AND mois_fin !='NA') 
				AND (annee_fin IS NOT NULL OR annee_fin!='' OR mois_fin!='NA')
				) THEN (jour_fin||'/'||mois_fin||'/'||annee_fin||' 23:59:59')::timestamp without time zone

			-- si seule une année de fin est définie, définir la date au 31 décembre 23h59m59s
			WHEN ( (hure_fin IS NULL OR hure_fin='' OR hure_fin='NA')
				AND (jour_fin IS NULL OR jour_fin='' OR jour_fin='NA')
				AND (mois_fin IS NULL OR mois_fin='' OR mois_fin='NA')
				AND (annee_fin IS NOT NULL AND annee_fin !='' AND mois_fin !='NA')
				) THEN ('31/12/'||annee_fin||' 23:59:59'):: timestamp without time zone

			-- si seuls une année et un mois de fin sont définis, fixer le dernier jour du mois 23h59m59s
			WHEN ( (hure_fin IS NULL OR hure_fin='' OR hure_fin='NA')
				AND (jour_fin IS NULL OR jour_fin='' OR jour_fin='NA')
				AND (mois_fin IS NOT NULL AND mois_fin!='' AND mois_fin!='NA')
				AND (annee_fin IS NOT NULL AND annee_fin!='' AND mois_fin!='NA')
				) THEN (CASE
					WHEN mois_fin='1' THEN ('31/01/'||annee_fin||' 23:59:59'):: timestamp without time zone -- janvier
					WHEN mois_fin='2' THEN ('27/02/'||annee_fin||' 23:59:59'):: timestamp without time zone -- février
					WHEN mois_fin='3' THEN ('31/03/'||annee_fin||' 23:59:59'):: timestamp without time zone -- mars
					WHEN mois_fin='4' THEN ('30/04/'||annee_fin||' 23:59:59'):: timestamp without time zone -- avril
					WHEN mois_fin='5' THEN ('31/05/'||annee_fin||' 23:59:59'):: timestamp without time zone -- mai
					WHEN mois_fin='6' THEN ('30/06/'||annee_fin||' 23:59:59'):: timestamp without time zone -- juin
					WHEN mois_fin='7' THEN ('31/07/'||annee_fin||' 23:59:59'):: timestamp without time zone -- juillet
					WHEN mois_fin='8' THEN ('31/08/'||annee_fin||' 23:59:59'):: timestamp without time zone -- aout
					WHEN mois_fin='9' THEN ('30/09/'||annee_fin||' 23:59:59'):: timestamp without time zone -- septembre
					WHEN mois_fin='10' THEN ('31/10/'||annee_fin||' 23:59:59'):: timestamp without time zone -- octobre
					WHEN mois_fin='11' THEN ('30/11/'||annee_fin||' 23:59:59'):: timestamp without time zone -- novembre
					WHEN mois_fin='12' THEN ('31/12/'||annee_fin||' 23:59:59'):: timestamp without time zone -- decembre
					END)

			-- si date fin totalement vide, la définir en fonction de la date de début
			WHEN ( (hure_fin IS NULL OR hure_fin='' OR hure_fin='NA') 
				AND (jour_fin IS NULL OR jour_fin='' OR jour_fin='NA')
				AND (mois_fin IS NULL OR mois_fin='' OR mois_fin='NA')
				AND (annee_fin IS NULL OR annee_fin='' OR mois_fin='NA')
				) THEN (CASE 
						-- si seule une année de début est définie, fixer la fin au 31 décembre de l'année 23h59m59
						WHEN ( (heure_debut IS NULL OR heure_debut='' OR heure_debut='NA') 
							AND (jour_debut IS NULL OR jour_debut='' OR jour_debut='NA')
							AND (mois_debut IS NULL OR mois_debut='' OR mois_debut='NA')
							) THEN ('31/12/'||annee_debut||' 23:59:59'):: timestamp without time zone
								
						-- si seuls une année et un mois de début sont définis, fixer la fin au dernier jour du mois 23h59m59
						WHEN ( (heure_debut IS NULL OR heure_debut='')  
							AND (jour_debut IS NULL OR jour_debut='' OR jour_debut='NA')
							AND (mois_debut IS NOT NULL AND mois_debut !='' AND mois_debut !='NA')
							) THEN (CASE
								WHEN mois_debut='1' THEN ('31/01/'||annee_debut||' 23:59:59'):: timestamp without time zone -- janvier
								WHEN mois_debut='2' THEN ('27/02/'||annee_debut||' 23:59:59'):: timestamp without time zone -- février
								WHEN mois_debut='3' THEN ('31/03/'||annee_debut||' 23:59:59'):: timestamp without time zone -- mars
								WHEN mois_debut='4' THEN ('30/04/'||annee_debut||' 23:59:59'):: timestamp without time zone -- avril
								WHEN mois_debut='5' THEN ('31/05/'||annee_debut||' 23:59:59'):: timestamp without time zone -- mai
								WHEN mois_debut='6' THEN ('30/06/'||annee_debut||' 23:59:59'):: timestamp without time zone -- juin	
								WHEN mois_debut='7' THEN ('31/07/'||annee_debut||' 23:59:59'):: timestamp without time zone -- juillet
								WHEN mois_debut='8' THEN ('31/08/'||annee_debut||' 23:59:59'):: timestamp without time zone -- aout
								WHEN mois_debut='9' THEN ('30/09/'||annee_debut||' 23:59:59'):: timestamp without time zone -- septembre
								WHEN mois_debut='10' THEN ('31/10/'||annee_debut||' 23:59:59'):: timestamp without time zone -- octobre
								WHEN mois_debut='11' THEN ('30/11/'||annee_debut||' 23:59:59'):: timestamp without time zone -- novembre
								WHEN mois_debut='12' THEN ('31/12/'||annee_debut||' 23:59:59'):: timestamp without time zone -- decembre
								END)
								
						-- si la date de fin est définie mais pas l'heure, fixer 23h59m59
						WHEN ( (heure_debut IS NULL OR heure_debut='' OR heure_debut='NA') 
							AND (jour_debut IS NOT NULL AND jour_debut !='' AND jour_debut !='NA')
							AND (mois_debut IS NOT NULL AND mois_debut !='' AND mois_debut !='NA') 
							) THEN (jour_debut||'/'||mois_debut||'/'||annee_debut||' 23:59:59')::timestamp without time zone
		
						-- si la date de début est complète, ne pas la modifier
						WHEN ( (heure_debut IS NOT NULL AND heure_debut !='' AND heure_debut !='NA') 
							AND (jour_debut IS NOT NULL AND jour_debut !='' AND jour_debut !='NA')
							AND (mois_debut IS NOT NULL AND mois_debut !='' AND mois_debut !='NA')
							) THEN (jour_debut||'/'||mois_debut||'/'||annee_debut||' '||heure_debut)::timestamp without time zone
					END)

		END::timestamp without time zone AS date_max

	FROM gn_imports.import_mabase a
	LEFT JOIN ref_nomenclatures.t_nomenclatures n ON a.methode_observation=n.mnemonique
	LEFT JOIN gn_imports.rattachement_mabase_taxref r ON a.nom_binomial=r.nom_binomial
	LEFT JOIN utilisateurs.t_roles u ON a.auteur_saisie=(SELECT(u.nom_role||' '||u.prenom_role))

--TODO 
-- Mettre à jour cor_observer_synthese(id_synthese,id_role)


-- Déplacement des tables d'origine dans le schéma "mabase historique"
CREATE SCHEMA monhistorique
  AUTHORIZATION monuser;
ALTER TABLE gn_imports.import_mabase SET SCHEMA monhistorique;
ALTER TABLE gn_imports.rattachement_mabase_taxref SET SCHEMA monhistorique;
