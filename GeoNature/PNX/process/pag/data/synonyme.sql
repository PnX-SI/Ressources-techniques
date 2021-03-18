-----------------------------------------------------------------------Creation de la compatibilité PAG
DROP SCHEMA IF EXISTS v1_compat CASCADE ;
DROP SCHEMA IF EXISTS gn_synchronomade CASCADE ;

CREATE SCHEMA v1_compat;
COMMENT ON SCHEMA v1_compat IS 'schéma contenant des objets permettant une compatibilité temporaire avec les outils mobiles de la V1';
CREATE SCHEMA gn_synchronomade;
COMMENT ON SCHEMA gn_synchronomade IS 'schéma contenant les erreurs de synchronisation et permettant une compatibilité temporaire avec les outils mobiles de la V1';

--On importe ici les schémas V1 meta et synthese pour faire les correspondances nécessaires
IMPORT FOREIGN SCHEMA synthese FROM SERVER geonature1server INTO v1_compat;
IMPORT FOREIGN SCHEMA meta FROM SERVER geonature1server INTO v1_compat;

--SET search_path = v1_compat, public, pg_catalog;





-----------------------------------------------
----- Création et alimentation cor_boolean ----
-----------------------------------------------
---------------------- Création et alimentation cor_boolean
CREATE TABLE v1_compat.cor_boolean
(
  expression character varying(25) NOT NULL,
  bool boolean NOT NULL
);
INSERT INTO v1_compat.cor_boolean VALUES('oui',true);
INSERT INTO v1_compat.cor_boolean VALUES('non',false);




-----------------------------------------------
--------     TRANSFERER LES SOURCES     -------
-----------------------------------------------
------------On déplace l'id de la source occtax
UPDATE gn_synthese.t_sources 
SET id_source = (SELECT max(id_source)+1 FROM v1_compat.bib_sources) 
WHERE name_source = 'Occtax';
--on insert ensuite les sources de la V1
INSERT INTO gn_synthese.t_sources (
	id_source,
  name_source,
  desc_source,
  entity_source_pk_field
)
SELECT 
  id_source, 
  nom_source, 
  desc_source, 
  'historique.' || db_schema || '_' || db_table || '.' || db_field AS entity_source_pk_field
FROM v1_compat.bib_sources;
SELECT setval('gn_synthese.t_sources_id_source_seq', (SELECT max(id_source)+1 FROM gn_synthese.t_sources), true);



-----------------------------------------------
--ETABLIR LES CORESPONDANCES DE NOMENCLATURES--
-----------------------------------------------
----------------Création de la table
DROP TABLE IF EXISTS v1_compat.cor_synthese_v1_to_v2 CASCADE ;
CREATE TABLE v1_compat.cor_synthese_v1_to_v2 (
	pk_source integer,
	entity_source character varying(100),
	lib_entity_source character varying(200),
	field_source character varying(50),
	entity_target character varying(100),
	lib_entity_target character varying(200),
	field_target character varying(50),
	id_type_nomenclature_cible integer,
	lib_type_cible character varying(200),
	id_nomenclature_cible integer,
	lib_nomenclature character varying(200),
	commentaire text,
	CONSTRAINT pk_cor_synthese_v1_to_v2 PRIMARY KEY (pk_source, entity_source, entity_target, field_target)
);
COMMENT ON TABLE v1_compat.cor_synthese_v1_to_v2 IS 'Permet de définir des correspondances entre le MCD de la V1 et celui de la V2';
COMMENT ON COLUMN v1_compat.cor_synthese_v1_to_v2.pk_source IS 'Valeur de la PK du champ de la table source pour laquelle une correspondance doit être établie';
COMMENT ON COLUMN v1_compat.cor_synthese_v1_to_v2.entity_source IS 'Table source (schema.table) utilisé pour la correspondance';
COMMENT ON COLUMN v1_compat.cor_synthese_v1_to_v2.lib_entity_source IS 'Libellé de la PK du champ de la table source pour laquelle une correspondance doit être établie';
COMMENT ON COLUMN v1_compat.cor_synthese_v1_to_v2.field_source IS 'Nom du champ de la table source (schema.table) utilisé pour la correspondance';
COMMENT ON COLUMN v1_compat.cor_synthese_v1_to_v2.entity_target IS 'Table cible (schema.table) utilisé pour la correspondance';
COMMENT ON COLUMN v1_compat.cor_synthese_v1_to_v2.field_target IS 'Nom du champ de la table cible (schema.table) utilisé pour la correspondance';
COMMENT ON COLUMN v1_compat.cor_synthese_v1_to_v2.lib_entity_target IS 'Libellé visé';
COMMENT ON COLUMN v1_compat.cor_synthese_v1_to_v2.id_type_nomenclature_cible IS 'Id_type de la nomenclature sur laquelle la correspondance en V2 est établie';
COMMENT ON COLUMN v1_compat.cor_synthese_v1_to_v2.lib_type_cible IS 'Libellé du type de nomenclature visé';
COMMENT ON COLUMN v1_compat.cor_synthese_v1_to_v2.id_nomenclature_cible IS 'id de la nomenclature sur laquelle la correspondance en V2 est établie';
COMMENT ON COLUMN v1_compat.cor_synthese_v1_to_v2.lib_nomenclature IS 'Libellé de la nomenclature visée';
ALTER TABLE ONLY v1_compat.cor_synthese_v1_to_v2
    ADD CONSTRAINT fk_cor_synthese_v1_to_v2_id_type_nomenclature FOREIGN KEY (id_type_nomenclature_cible) REFERENCES ref_nomenclatures.bib_nomenclatures_types(id_type) ON UPDATE CASCADE ON DELETE NO ACTION;
ALTER TABLE ONLY v1_compat.cor_synthese_v1_to_v2
    ADD CONSTRAINT fk_cor_synthese_v1_to_v2_t_nomenclatures FOREIGN KEY (id_nomenclature_cible) REFERENCES ref_nomenclatures.t_nomenclatures(id_nomenclature) ON UPDATE CASCADE ON DELETE NO ACTION;

CREATE INDEX i_cor_synthese_v1_to_v2_pk_source
  ON v1_compat.cor_synthese_v1_to_v2
  USING btree
  (pk_source);
 
CREATE INDEX i_cor_synthese_v1_to_v2_id_nomenclature_cible
  ON v1_compat.cor_synthese_v1_to_v2
  USING btree
  (id_nomenclature_cible);


--NATURE DE L'OBJET GEOGRAPHIQUE NAT_OBJ_GEO  avec les champs ,lib_entity_source, lib_entity_target, lib_type_cible, lib_nomenclature
--ne sait pas
INSERT INTO v1_compat.cor_synthese_v1_to_v2 (pk_source, entity_source, field_source, entity_target, field_target, id_type_nomenclature_cible, id_nomenclature_cible,lib_entity_source, lib_type_cible, lib_nomenclature, commentaire )
SELECT 
    id_precision, 
    'v1_compat.t_precisions' AS entity_source, 
    'id_precision' as entity_source, 
    'gn_synthese.synthese' AS entity_target, 
    'id_nomenclature_geo_object_nature' AS field_target, 
    3 AS id_type_nomenclature_cible, 
    ref_nomenclatures.get_id_nomenclature('NAT_OBJ_GEO','NSP') AS id_nomenclature_cible,
	nom_precision, 
	'NAT_OBJ_GEO' AS lib_type_cible, 
	'NSP' AS lib_nomenclature,
	'Objet géo. non précisé' AS commentaire
FROM v1_compat.t_precisions
ORDER BY id_precision;
--stationnel
UPDATE v1_compat.cor_synthese_v1_to_v2
SET id_nomenclature_cible = ref_nomenclatures.get_id_nomenclature('NAT_OBJ_GEO','St'),
lib_type_cible = 'NAT_OBJ_GEO',
lib_nomenclature = 'St', 
commentaire = 'Objet géo. stationnel'
WHERE pk_source IN(1,2,3,4,10)
AND entity_source = 'v1_compat.t_precisions'
AND field_source = 'id_precision'
AND entity_target = 'gn_synthese.synthese'
AND field_target = 'id_nomenclature_geo_object_nature';
--inventoriel
UPDATE v1_compat.cor_synthese_v1_to_v2
SET id_nomenclature_cible = ref_nomenclatures.get_id_nomenclature('NAT_OBJ_GEO','In'),
lib_type_cible = 'NAT_OBJ_GEO',
lib_nomenclature = 'In', 
commentaire = 'Objet géo. inventoriel'
WHERE pk_source IN(5,6,7,8,9,11,13,14)
AND entity_source = 'v1_compat.t_precisions'
AND field_source = 'id_precision'
AND entity_target = 'gn_synthese.synthese'
AND field_target = 'id_nomenclature_geo_object_nature';



--TYPE DE REGROUPEMENT TYP_GRP
--observation
INSERT INTO v1_compat.cor_synthese_v1_to_v2 (pk_source, entity_source, field_source, entity_target, field_target, id_type_nomenclature_cible, id_nomenclature_cible,lib_entity_source, lib_type_cible, lib_nomenclature, commentaire )
SELECT id_lot, 
	'v1_compat.bib_lots' AS entity_source, 
	'id_lot' as entity_source, 
	'gn_synthese.synthese' AS entity_target, 
	'id_nomenclature_grp_typ' AS field_target, 
	24 AS id_type_nomenclature_cible, 
	ref_nomenclatures.get_id_nomenclature('TYP_GRP','OBS') AS id_nomenclature_cible, 
	nom_lot, 
	'TYP_GRP' AS lib_type_cible, 
	'OBS' AS lib_nomenclature,
	'Obs.- Observations' AS commentaire 
FROM v1_compat.bib_lots
ORDER BY id_lot;

--Inventaire stationnel -----------------------------------------Flore station et bryophytes
UPDATE v1_compat.cor_synthese_v1_to_v2
SET id_nomenclature_cible = ref_nomenclatures.get_id_nomenclature('TYP_GRP','INVSTA'),
lib_type_cible = 'TYP_GRP',
lib_nomenclature = 'INVSTA', 
commentaire = 'Obs.- Inventaire stationnel'
WHERE pk_source IN(5,6)  
AND entity_source = 'v1_compat.bib_lots' 
AND field_source = 'id_lot' 
AND entity_target = 'gn_synthese.synthese' 
AND field_target = 'id_nomenclature_grp_typ';
--Point de prélèvement ou point d'observation. -------------------Etudes mamm et rongeurs
UPDATE v1_compat.cor_synthese_v1_to_v2
SET id_nomenclature_cible = ref_nomenclatures.get_id_nomenclature('TYP_GRP','POINT'),
lib_type_cible = 'TYP_GRP',
lib_nomenclature = 'POINT', 
commentaire = 'Obs.- Point de prélèvement ou point d''observation'
WHERE pk_source IN(21)
AND entity_source = 'v1_compat.bib_lots' AND field_source = 'id_lot' AND entity_target = 'gn_synthese.synthese' AND field_target = 'id_nomenclature_grp_typ';
--Passage (pour les comptages) -----------------------------------IKA et STOC
UPDATE v1_compat.cor_synthese_v1_to_v2
SET id_nomenclature_cible = ref_nomenclatures.get_id_nomenclature('TYP_GRP','PASS'),
lib_type_cible = 'TYP_GRP',
lib_nomenclature = 'PASS', 
commentaire = 'Obs.- Passage (pour les comptages)'
WHERE pk_source IN(19,20)
AND entity_source = 'v1_compat.bib_lots' AND field_source = 'id_lot' AND entity_target = 'gn_synthese.synthese' AND field_target = 'id_nomenclature_grp_typ';
--Ne sait pas
--UPDATE v1_compat.cor_synthese_v1_to_v2
--SET id_nomenclature_cible = ref_nomenclatures.get_id_nomenclature('TYP_GRP','NSP')
--WHERE pk_source IN(111,107,47,8,24,43)
--AND entity_source = 'v1_compat.bib_lots' AND field_source = 'id_lot' AND entity_target = 'gn_synthese.synthese' AND field_target = 'id_nomenclature_grp_typ';



--METHODE d'OBSERVATION METH_OBS 
INSERT INTO v1_compat.cor_synthese_v1_to_v2 (pk_source, entity_source, field_source, entity_target, field_target, id_type_nomenclature_cible, id_nomenclature_cible,lib_entity_source, lib_type_cible, lib_nomenclature, commentaire )
SELECT id_critere_synthese, 
	'v1_compat.bib_criteres_synthese' AS entity_source, 
	'id_critere_synthese' as entity_source, 
	'gn_synthese.synthese' AS entity_target, 'id_nomenclature_obs_meth' AS field_target, 
	14 AS id_type_nomenclature_cible, 
	ref_nomenclatures.get_id_nomenclature('METH_OBS','21') AS id_nomenclature_cible, 
	nom_critere_synthese, 
	'METH_OBS' AS lib_type_cible, 
	'21' AS lib_nomenclature,
	'Méthodes d''obs.- Inconnu' AS commentaire 
FROM v1_compat.bib_criteres_synthese;
--vu
UPDATE v1_compat.cor_synthese_v1_to_v2
SET id_nomenclature_cible = ref_nomenclatures.get_id_nomenclature('METH_OBS','0'),
lib_type_cible = 'METH_OBS',
lib_nomenclature = '0', 
commentaire = 'Obs.- Vu'
WHERE pk_source IN(2,5,6,8,9,10,11,12,14,16,18,21,22,23,26,27,29,30,31,33,34,35,37,38,101,102,103,201,204,208,209,214,215,217,221,222,224,226)
AND entity_source = 'v1_compat.bib_criteres_synthese' AND field_source = 'id_critere_synthese' AND entity_target = 'gn_synthese.synthese' AND field_target = 'id_nomenclature_obs_meth';
--Entendu
UPDATE v1_compat.cor_synthese_v1_to_v2
SET id_nomenclature_cible = ref_nomenclatures.get_id_nomenclature('METH_OBS','1'),
lib_type_cible = 'METH_OBS',
lib_nomenclature = '1', 
commentaire = 'Obs.- Entendu'
WHERE pk_source IN(4,7,207)
AND entity_source = 'v1_compat.bib_criteres_synthese' AND field_source = 'id_critere_synthese' AND entity_target = 'gn_synthese.synthese' AND field_target = 'id_nomenclature_obs_meth';
--Empreintes
UPDATE v1_compat.cor_synthese_v1_to_v2
SET id_nomenclature_cible = ref_nomenclatures.get_id_nomenclature('METH_OBS','4'),
lib_type_cible = 'METH_OBS',
lib_nomenclature = '4', 
commentaire = 'Obs.- Empreintes'
WHERE pk_source IN(3,219)
AND entity_source = 'v1_compat.bib_criteres_synthese' AND field_source = 'id_critere_synthese' AND entity_target = 'gn_synthese.synthese' AND field_target = 'id_nomenclature_obs_meth';
--"Fèces/Guano/Epreintes"
UPDATE v1_compat.cor_synthese_v1_to_v2
SET id_nomenclature_cible = ref_nomenclatures.get_id_nomenclature('METH_OBS','6'),
lib_type_cible = 'METH_OBS',
lib_nomenclature = '6', 
commentaire = 'Obs.- Fèces/Guano/Epreintes'
WHERE pk_source IN(205)
AND entity_source = 'v1_compat.bib_criteres_synthese' AND field_source = 'id_critere_synthese' AND entity_target = 'gn_synthese.synthese' AND field_target = 'id_nomenclature_obs_meth';
--Nid/Gîte
UPDATE v1_compat.cor_synthese_v1_to_v2
SET id_nomenclature_cible = ref_nomenclatures.get_id_nomenclature('METH_OBS','8'),
lib_type_cible = 'METH_OBS',
lib_nomenclature = '8', 
commentaire = 'Obs.- Nid/Gîte'
WHERE pk_source IN(13,15,17,19,20,216)
AND entity_source = 'v1_compat.bib_criteres_synthese' AND field_source = 'id_critere_synthese' AND entity_target = 'gn_synthese.synthese' AND field_target = 'id_nomenclature_obs_meth';
--Restes de repas
UPDATE v1_compat.cor_synthese_v1_to_v2
SET id_nomenclature_cible = ref_nomenclatures.get_id_nomenclature('METH_OBS','12'),
lib_type_cible = 'METH_OBS',
lib_nomenclature = '12', 
commentaire = 'Obs.- Restes de repas'
WHERE pk_source IN(211)
AND entity_source = 'v1_compat.bib_criteres_synthese' AND field_source = 'id_critere_synthese' AND entity_target = 'gn_synthese.synthese' AND field_target = 'id_nomenclature_obs_meth';
--Autres
UPDATE v1_compat.cor_synthese_v1_to_v2
SET id_nomenclature_cible = ref_nomenclatures.get_id_nomenclature('METH_OBS','20'),
lib_type_cible = 'METH_OBS',
lib_nomenclature = '20', 
commentaire = 'Obs.- Autres'
WHERE pk_source IN(105,203,220)
AND entity_source = 'v1_compat.bib_criteres_synthese' AND field_source = 'id_critere_synthese' AND entity_target = 'gn_synthese.synthese' AND field_target = 'id_nomenclature_obs_meth';
--Galerie/terrier
UPDATE v1_compat.cor_synthese_v1_to_v2
SET id_nomenclature_cible = ref_nomenclatures.get_id_nomenclature('METH_OBS','23'),
lib_type_cible = 'METH_OBS',
lib_nomenclature = '23', 
commentaire = 'Obs.- Galerie/terrier'
WHERE pk_source IN(24,25)
AND entity_source = 'v1_compat.bib_criteres_synthese' AND field_source = 'id_critere_synthese' AND entity_target = 'gn_synthese.synthese' AND field_target = 'id_nomenclature_obs_meth';


--STATUT BIOLOGIQUE STATUT_BIO 
--non détermminé
INSERT INTO v1_compat.cor_synthese_v1_to_v2 (pk_source, entity_source, field_source, entity_target, field_target, id_type_nomenclature_cible, id_nomenclature_cible,lib_entity_source, lib_type_cible, lib_nomenclature, commentaire )
SELECT id_critere_synthese, 
	'v1_compat.bib_criteres_synthese' AS entity_source, 
	'id_critere_synthese' as entity_source, 
	'gn_synthese.synthese' AS entity_target, 
	'id_nomenclature_bio_status' AS field_target, 
	13 AS id_type_nomenclature_cible, 
	ref_nomenclatures.get_id_nomenclature('STATUT_BIO','0') AS id_nomenclature_cible, 
	nom_critere_synthese, 
	'STATUT_BIO' AS lib_type_cible, 
	'0' AS lib_nomenclature,
	'Statut bio.- Inconnu'	as commentaire 
FROM v1_compat.bib_criteres_synthese;
--Reproduction
UPDATE v1_compat.cor_synthese_v1_to_v2
SET id_nomenclature_cible = ref_nomenclatures.get_id_nomenclature('STATUT_BIO','3'),
lib_type_cible = 'STATUT_BIO',
lib_nomenclature = '3', 
commentaire = 'Statut bio.- Reproduction'
WHERE pk_source IN(10,11,12,13,14,15,16,17,18,19,20,21,22,23,27,28,29,31,32,33,35,36,37,101,102,204,209,215,216,221,224,222,226)
AND entity_source = 'v1_compat.bib_criteres_synthese' AND field_source = 'id_critere_synthese' AND entity_target = 'gn_synthese.synthese' AND field_target = 'id_nomenclature_bio_status';
--Hibernation
UPDATE v1_compat.cor_synthese_v1_to_v2
SET id_nomenclature_cible = ref_nomenclatures.get_id_nomenclature('STATUT_BIO','4'),
lib_type_cible = 'STATUT_BIO',
lib_nomenclature = '4', 
commentaire = 'Statut bio.- Hibernation'
WHERE pk_source IN(26)
AND entity_source = 'v1_compat.bib_criteres_synthese' AND field_source = 'id_critere_synthese' AND entity_target = 'gn_synthese.synthese' AND field_target = 'id_nomenclature_bio_status';


--ETAT BIOLOGIQUE ETA_BIO
--vivant
INSERT INTO v1_compat.cor_synthese_v1_to_v2 (pk_source, entity_source, field_source, entity_target, field_target, id_type_nomenclature_cible, id_nomenclature_cible,lib_entity_source, lib_type_cible, lib_nomenclature, commentaire )
SELECT id_critere_synthese, 
	'v1_compat.bib_criteres_synthese' AS entity_source, 
	'id_critere_synthese' as entity_source, 
	'gn_synthese.synthese' AS entity_target, 
	'id_nomenclature_bio_condition' AS field_target, 
	7 AS id_type_nomenclature_cible, 
	ref_nomenclatures.get_id_nomenclature('ETA_BIO','2') AS id_nomenclature_cible, 
	nom_critere_synthese, 
	'ETA_BIO' AS lib_type_cible, 
	'2' AS lib_nomenclature,
	'Etat bio.- Vivant'	as commentaire
FROM v1_compat.bib_criteres_synthese;
--trouvé mort
UPDATE v1_compat.cor_synthese_v1_to_v2
SET id_nomenclature_cible = ref_nomenclatures.get_id_nomenclature('ETA_BIO','3'),
lib_type_cible = 'ETA_BIO',
lib_nomenclature = '3', 
commentaire = 'Etat bio.- Mort'
WHERE pk_source IN(2)
AND entity_source = 'v1_compat.bib_criteres_synthese' AND field_source = 'id_critere_synthese' AND entity_target = 'gn_synthese.synthese' AND field_target = 'id_nomenclature_bio_condition';
-- Ne sait pas
UPDATE v1_compat.cor_synthese_v1_to_v2
SET id_nomenclature_cible = ref_nomenclatures.get_id_nomenclature('ETA_BIO','0'),
lib_type_cible = 'ETA_BIO',
lib_nomenclature = '0', 
commentaire = 'Etat bio.- Ne sais pas.'
WHERE pk_source IN(1, 25)
AND entity_source = 'v1_compat.bib_criteres_synthese' AND field_source = 'id_critere_synthese' AND entity_target = 'gn_synthese.synthese' AND field_target = 'id_nomenclature_bio_condition';



--NATURALITE NATURALITE 
--sauvage
INSERT INTO v1_compat.cor_synthese_v1_to_v2 (pk_source, entity_source, field_source, entity_target, field_target, id_type_nomenclature_cible, id_nomenclature_cible,lib_entity_source, lib_type_cible, lib_nomenclature, commentaire)
SELECT id_lot, 
	'v1_compat.bib_lots' AS entity_source, 
	'id_lot' as entity_source, 
	'gn_synthese.synthese' AS entity_target, 
	'id_nomenclature_naturalness' AS field_target, 
	8 AS id_type_nomenclature_cible, 
	ref_nomenclatures.get_id_nomenclature('NATURALITE','1') AS id_nomenclature_cible, 
	nom_lot,
	'NATURALITE' AS lib_type_cible, 
	'1' AS lib_nomenclature,
	'Naturalité- Sauvage'	as commentaire 
FROM v1_compat.bib_lots;



--PREUVE D'EXISTANCE PREUVE_EXIST 
--DELETE FROM v1_compat.cor_synthese_v1_to_v2 WHERE id_type_nomenclature_cible = 15
--non/sans preuve
INSERT INTO v1_compat.cor_synthese_v1_to_v2 (pk_source, entity_source, field_source, entity_target, field_target, id_type_nomenclature_cible, id_nomenclature_cible,lib_entity_source, lib_type_cible, lib_nomenclature, commentaire)
SELECT id_source, 
	'v1_compat.bib_sources' AS entity_source, 
	'id_source' as entity_source, 
	'gn_synthese.synthese' AS entity_target, 
	'id_nomenclature_exist_proof' AS field_target, 
	15 AS id_type_nomenclature_cible, 
	ref_nomenclatures.get_id_nomenclature('PREUVE_EXIST','2') AS id_nomenclature_cible, 
	nom_source,
	'PREUVE_EXIST' AS lib_type_cible, 
	'2' AS lib_nomenclature,
	'Preuve- Pas de preuve'	as commentaire  
FROM v1_compat.bib_sources;
--avec preuve (Herbier) 
UPDATE v1_compat.cor_synthese_v1_to_v2
SET id_nomenclature_cible = ref_nomenclatures.get_id_nomenclature('PREUVE_EXIST','1'),
lib_type_cible = 'PREUVE_EXIST',
lib_nomenclature = '1', 
commentaire = 'Preuve- oui/avec preuves accessibles'
WHERE pk_source IN(35) 
AND entity_source = 'v1_compat.bib_sources' AND field_source = 'id_source' AND entity_target = 'gn_synthese.synthese' AND field_target = 'id_nomenclature_exist_proof';
--non acquise (chasse et pêche)
UPDATE v1_compat.cor_synthese_v1_to_v2
SET id_nomenclature_cible = ref_nomenclatures.get_id_nomenclature('PREUVE_EXIST','3'),
lib_type_cible = 'PREUVE_EXIST',
lib_nomenclature = '3', 
commentaire = 'Preuve- Preuve non acquise'
WHERE pk_source IN(8,22) 
AND entity_source = 'v1_compat.bib_sources' AND field_source = 'id_source' AND entity_target = 'gn_synthese.synthese' AND field_target = 'id_nomenclature_exist_proof';
--Ne sais pas
UPDATE v1_compat.cor_synthese_v1_to_v2
SET id_nomenclature_cible = ref_nomenclatures.get_id_nomenclature('PREUVE_EXIST','0'),
lib_type_cible = 'PREUVE_EXIST',
lib_nomenclature = '0', 
commentaire = 'Preuve- Ne sais pas'
WHERE pk_source IN(24, 25) 
AND entity_source = 'v1_compat.bib_sources' AND field_source = 'id_source' AND entity_target = 'gn_synthese.synthese' AND field_target = 'id_nomenclature_exist_proof';


--STATUT DE VALIDATION STATUT_VALID
--DELETE FROM v1_compat.cor_synthese_v1_to_v2 WHERE id_type_nomenclature_cible = 101
--probable (données PNE)
INSERT INTO v1_compat.cor_synthese_v1_to_v2 (pk_source, entity_source, field_source, entity_target, field_target, id_type_nomenclature_cible, id_nomenclature_cible,lib_entity_source, lib_type_cible, lib_nomenclature, commentaire)
SELECT id_source, 
	'v1_compat.bib_sources' AS entity_source, 
	'id_source' as entity_source, 
	'gn_synthese.synthese' AS entity_target, 
	'id_nomenclature_valid_status' AS field_target, 
	101 AS id_type_nomenclature_cible, 
	ref_nomenclatures.get_id_nomenclature('STATUT_VALID','2') AS id_nomenclature_cible, 
	nom_source,
	'STATUT_VALID' AS lib_type_cible, 
	'2' AS lib_nomenclature,
	'Validation- Probable'	as commentaire  
FROM v1_compat.bib_sources;
--Certain - très probable (données Faune-Guyane, chasse, pêche, CEBA et ZNIEFF)
UPDATE v1_compat.cor_synthese_v1_to_v2
SET id_nomenclature_cible = ref_nomenclatures.get_id_nomenclature('STATUT_VALID','1'),
lib_type_cible = 'STATUT_VALID',
lib_nomenclature = '1', 
commentaire = 'Validation- Certain/très probable'
WHERE pk_source IN(8,10,35,12,11,13,14,15,16,17,18,20,21,22,24,23,25,26,27,29,28,31,30,32,34,33,9,38)
AND entity_source = 'v1_compat.bib_sources' AND field_source = 'id_source' AND entity_target = 'gn_synthese.synthese' AND field_target = 'id_nomenclature_valid_status';



--NIVEAU DE DIFFUSION NIV_PRECIS 
--DELETE FROM v1_compat.cor_synthese_v1_to_v2 WHERE id_type_nomenclature_cible = 5
--Précises (données PNE). a affiner données par données une fois la sensibilité définie.
INSERT INTO v1_compat.cor_synthese_v1_to_v2 (pk_source, entity_source, field_source, entity_target, field_target, id_type_nomenclature_cible, id_nomenclature_cible,lib_entity_source, lib_type_cible, lib_nomenclature, commentaire)
SELECT id_source, 
	'v1_compat.bib_sources' AS entity_source, 
	'id_source' as entity_source, 
	'gn_synthese.synthese' AS entity_target, 
	'id_nomenclature_diffusion_level' AS field_target, 
	5 AS id_type_nomenclature_cible, 
	ref_nomenclatures.get_id_nomenclature('NIV_PRECIS','5') AS id_nomenclature_cible, 
	nom_source,
	'NIV_PRECIS' AS lib_type_cible, 
	'5' AS lib_nomenclature,
	'Diffusion- Précise'	as commentaire 
FROM v1_compat.bib_sources;
--aucune (sources des partenaires: GEPOG, Herbier, CEBA)
UPDATE v1_compat.cor_synthese_v1_to_v2
SET id_nomenclature_cible = ref_nomenclatures.get_id_nomenclature('NIV_PRECIS','4'),
lib_type_cible = 'NIV_PRECIS',
lib_nomenclature = '4', 
commentaire = 'Diffusion- pas de diff. partenaires'
WHERE pk_source IN(24, 25, 35)
AND entity_source = 'v1_compat.bib_sources' AND field_source = 'id_source' AND entity_target = 'gn_synthese.synthese' AND field_target = 'id_nomenclature_diffusion_level';


--STADE DE VIE - AGE - PHENOLOGIE STADE_VIE 
--DELETE FROM v1_compat.cor_synthese_v1_to_v2 WHERE id_type_nomenclature_cible = 10
--Selon les critères d'obs
INSERT INTO v1_compat.cor_synthese_v1_to_v2 (pk_source, entity_source, field_source, entity_target, field_target, id_type_nomenclature_cible, id_nomenclature_cible,lib_entity_source, lib_type_cible, lib_nomenclature, commentaire )
SELECT id_critere_synthese, 
	'v1_compat.bib_criteres_synthese' AS entity_source, 
	'id_critere_synthese' as entity_source, 
	'gn_synthese.synthese' AS entity_target, 
	'id_nomenclature_life_stage' AS field_target, 
	10 AS id_type_nomenclature_cible, 
	ref_nomenclatures.get_id_nomenclature('STADE_VIE','0') AS id_nomenclature_cible, 
	nom_critere_synthese, 
	'STADE_VIE' AS lib_type_cible, 
	'0' AS lib_nomenclature,
	'Stade de vie - Inconnu' as commentaire
FROM v1_compat.bib_criteres_synthese;
-- Adulte
UPDATE v1_compat.cor_synthese_v1_to_v2
SET id_nomenclature_cible = ref_nomenclatures.get_id_nomenclature('STADE_VIE','2'),
lib_type_cible = 'STADE_VIE',
lib_nomenclature = '2', 
commentaire = 'Stade de vie- Adulte'
WHERE pk_source IN(7,8,9,10,11,12,13,14,18,21,22,23,27,31,35,102,103,214,215,221,226)
AND entity_source = 'v1_compat.bib_criteres_synthese' AND field_source = 'id_critere_synthese' AND entity_target = 'gn_synthese.synthese' AND field_target = 'id_nomenclature_life_stage';
-- Immature
UPDATE v1_compat.cor_synthese_v1_to_v2
SET id_nomenclature_cible = ref_nomenclatures.get_id_nomenclature('STADE_VIE','4'),
lib_type_cible = 'STADE_VIE',
lib_nomenclature = '4', 
commentaire = 'Stade de vie- Immature'
WHERE pk_source IN(6)
AND entity_source = 'v1_compat.bib_criteres_synthese' AND field_source = 'id_critere_synthese' AND entity_target = 'gn_synthese.synthese' AND field_target = 'id_nomenclature_life_stage';
-- Juvénile
UPDATE v1_compat.cor_synthese_v1_to_v2
SET id_nomenclature_cible = ref_nomenclatures.get_id_nomenclature('STADE_VIE','3'),
lib_type_cible = 'STADE_VIE',
lib_nomenclature = '3', 
commentaire = 'Stade de vie- Juvénile'
WHERE pk_source IN(16,29, 20,209)
AND entity_source = 'v1_compat.bib_criteres_synthese' AND field_source = 'id_critere_synthese' AND entity_target = 'gn_synthese.synthese' AND field_target = 'id_nomenclature_life_stage';
-- Ponte
UPDATE v1_compat.cor_synthese_v1_to_v2
SET id_nomenclature_cible = ref_nomenclatures.get_id_nomenclature('STADE_VIE','9'),
lib_type_cible = 'STADE_VIE',
lib_nomenclature = '9', 
commentaire = 'Stade de vie- Oeufs'
WHERE pk_source IN(19, 28,32,36)
AND entity_source = 'v1_compat.bib_criteres_synthese' AND field_source = 'id_critere_synthese' AND entity_target = 'gn_synthese.synthese' AND field_target = 'id_nomenclature_life_stage';
-- Têtard
UPDATE v1_compat.cor_synthese_v1_to_v2
SET id_nomenclature_cible = ref_nomenclatures.get_id_nomenclature('STADE_VIE','8'),
lib_type_cible = 'STADE_VIE',
lib_nomenclature = '8', 
commentaire = 'Stade de vie- Tétard'
WHERE pk_source IN(33)
AND entity_source = 'v1_compat.bib_criteres_synthese' AND field_source = 'id_critere_synthese' AND entity_target = 'gn_synthese.synthese' AND field_target = 'id_nomenclature_life_stage';
-- Alevin/larve
UPDATE v1_compat.cor_synthese_v1_to_v2
SET id_nomenclature_cible = ref_nomenclatures.get_id_nomenclature('STADE_VIE','17'),
lib_type_cible = 'STADE_VIE',
lib_nomenclature = '17', 
commentaire = 'Stade de vie- Alevin'
WHERE pk_source IN(37)
AND entity_source = 'v1_compat.bib_criteres_synthese' AND field_source = 'id_critere_synthese' AND entity_target = 'gn_synthese.synthese' AND field_target = 'id_nomenclature_life_stage';
-- Larve
UPDATE v1_compat.cor_synthese_v1_to_v2
SET id_nomenclature_cible = ref_nomenclatures.get_id_nomenclature('STADE_VIE','6'),
lib_type_cible = 'STADE_VIE',
lib_nomenclature = '6', 
commentaire = 'Stade de vie- Larve'
WHERE pk_source IN(101)
AND entity_source = 'v1_compat.bib_criteres_synthese' AND field_source = 'id_critere_synthese' AND entity_target = 'gn_synthese.synthese' AND field_target = 'id_nomenclature_life_stage';

--SEXE SEXE 
--DELETE FROM v1_compat.cor_synthese_v1_to_v2 WHERE id_type_nomenclature_cible = 9
--Non renseigné. A affiner données par données en fonction de la scturturation dans les tables sources.
INSERT INTO v1_compat.cor_synthese_v1_to_v2 (pk_source, entity_source, field_source, entity_target, field_target, id_type_nomenclature_cible, id_nomenclature_cible,lib_entity_source, lib_type_cible, lib_nomenclature, commentaire )
SELECT id_critere_synthese, 
	'v1_compat.bib_criteres_synthese' AS entity_source, 
	'id_critere_synthese' as entity_source, 
	'gn_synthese.synthese' AS entity_target, 
	'id_nomenclature_sex' AS field_target, 
	9 AS id_type_nomenclature_cible, 
	ref_nomenclatures.get_id_nomenclature('SEXE','6') AS id_nomenclature_cible, 
	nom_critere_synthese, 
	'SEXE' AS lib_type_cible, 
	'6' AS lib_nomenclature,
	'Sexe- Non renseigné' as commentaire
FROM v1_compat.bib_criteres_synthese;
-- Mâle
UPDATE v1_compat.cor_synthese_v1_to_v2
SET id_nomenclature_cible = ref_nomenclatures.get_id_nomenclature('SEXE','3'),
lib_type_cible = 'SEXE',
lib_nomenclature = '3', 
commentaire = 'Sexe- Mâle'
WHERE pk_source IN(7)
AND entity_source = 'v1_compat.bib_criteres_synthese' AND field_source = 'id_critere_synthese' AND entity_target = 'gn_synthese.synthese' AND field_target = 'id_nomenclature_sex';
-- Femelle
UPDATE v1_compat.cor_synthese_v1_to_v2
SET id_nomenclature_cible = ref_nomenclatures.get_id_nomenclature('SEXE','2'),
lib_type_cible = 'SEXE',
lib_nomenclature = '2', 
commentaire = 'Sexe- Femelle'
WHERE pk_source IN(12,22,23)
AND entity_source = 'v1_compat.bib_criteres_synthese' AND field_source = 'id_critere_synthese' AND entity_target = 'gn_synthese.synthese' AND field_target = 'id_nomenclature_sex';
-- Mixte
UPDATE v1_compat.cor_synthese_v1_to_v2
SET id_nomenclature_cible = ref_nomenclatures.get_id_nomenclature('SEXE','5'),
lib_type_cible = 'SEXE',
lib_nomenclature = '5', 
commentaire = 'Sexe- Mixte'
WHERE pk_source IN(8,10,21,27,35,102)
AND entity_source = 'v1_compat.bib_criteres_synthese' AND field_source = 'id_critere_synthese' AND entity_target = 'gn_synthese.synthese' AND field_target = 'id_nomenclature_sex';



--OBJET DU DENOMBREMENT OBJ_DENBR 
--DELETE FROM v1_compat.cor_synthese_v1_to_v2 WHERE id_type_nomenclature_cible = 6
--A l'individu. A affiner données par données en fonction de la structuration dans les tables sources.
INSERT INTO v1_compat.cor_synthese_v1_to_v2 (pk_source, entity_source, field_source, entity_target, field_target, id_type_nomenclature_cible, id_nomenclature_cible,lib_entity_source, lib_type_cible, lib_nomenclature, commentaire)
SELECT id_source, 
	'v1_compat.bib_sources' AS entity_source, 
	'id_source' as entity_source, 
	'gn_synthese.synthese' AS entity_target, 
	'id_nomenclature_obj_count' AS field_target, 
	6 AS id_type_nomenclature_cible, 
	ref_nomenclatures.get_id_nomenclature('OBJ_DENBR','IND') AS id_nomenclature_cible, 
	nom_source, 
	'OBJ_DENBR' AS lib_type_cible, 
	'IND' AS lib_nomenclature,
	'Obj. dénombr- Individu' as commentaire 
FROM v1_compat.bib_sources;
--Ne sais pas
UPDATE v1_compat.cor_synthese_v1_to_v2
SET id_nomenclature_cible = ref_nomenclatures.get_id_nomenclature('OBJ_DENBR','NSP'),
lib_type_cible = 'OBJ_DENBR',
lib_nomenclature = 'NSP', 
commentaire = 'Obj. dénombr- NSP'
WHERE pk_source IN(0,6,7,3,35,37)
AND entity_source = 'v1_compat.bib_sources' AND field_source = 'id_source' AND entity_target = 'gn_synthese.synthese' AND field_target = 'id_nomenclature_obj_count';


--TYPE DE DENOMBREMENT TYP_DENBR 
--DELETE FROM v1_compat.cor_synthese_v1_to_v2 WHERE id_type_nomenclature_cible = 21
--Ne sait pas. Pour toutes les sources. A voir si possibilité d'affiner
INSERT INTO v1_compat.cor_synthese_v1_to_v2 (pk_source, entity_source, field_source, entity_target, field_target, id_type_nomenclature_cible, id_nomenclature_cible,lib_entity_source, lib_type_cible, lib_nomenclature, commentaire)
SELECT id_source, 'v1_compat.bib_sources' AS entity_source, 'id_source' as entity_source, 'gn_synthese.synthese' AS entity_target, 'id_nomenclature_type_count' AS field_target, 21 AS id_type_nomenclature_cible, ref_nomenclatures.get_id_nomenclature('TYP_DENBR','NSP') AS id_nomenclature_cible , 
	nom_source, 
	'TYP_DENBR' AS lib_type_cible, 
	'NSP' AS lib_nomenclature,
	'Type dénombr- Individu' as commentaire 
FROM v1_compat.bib_sources;


--SENSIBILITE
--A calculer ou définir au caspar cas. Mise à "NULL" en attendant


--FLOUTAGE
--PAG : A ma connaissance aucune donnée PNE ou partenaire n'a été dégradée : id_nomenclature_blurring = 200


--TYPE D'INFORMATION GEOGRAPHIQUE (géoréférencement ou rattachement) TYP_INF_GEO
--DELETE FROM v1_compat.cor_synthese_v1_to_v2 WHERE id_type_nomenclature_cible = 23
--Géoréférencement.  
INSERT INTO v1_compat.cor_synthese_v1_to_v2 (pk_source, entity_source, field_source, entity_target, field_target, id_type_nomenclature_cible, id_nomenclature_cible,lib_entity_source, lib_type_cible, lib_nomenclature, commentaire)
SELECT id_precision, 'v1_compat.t_precisions' AS entity_source, 'id_precision' as entity_source, 'gn_synthese.synthese' AS entity_target, 'id_nomenclature_info_geo_type' AS field_target, 23 AS id_type_nomenclature_cible, ref_nomenclatures.get_id_nomenclature('TYP_INF_GEO','1') AS id_nomenclature_cible  , 
	nom_precision, 
	'TYP_INF_GEO' AS lib_type_cible, 
	'1' AS lib_nomenclature,
	'Type géoref- Georeference' as commentaire 
FROM v1_compat.t_precisions;
--rattachement - Faune Guyane !
UPDATE v1_compat.cor_synthese_v1_to_v2
SET id_nomenclature_cible = ref_nomenclatures.get_id_nomenclature('TYP_INF_GEO','2')
WHERE pk_source IN(5,6,7,8,9,11,13,14)
AND entity_source = 'v1_compat.t_precisions' AND field_source = 'id_precision' AND entity_target = 'gn_synthese.synthese' AND field_target = 'id_nomenclature_info_geo_type';



---------------------------------------- synonyme
DROP TABLE IF EXISTS v1_compat.t_synonymes_v1;
CREATE TABLE v1_compat.t_synonymes_v1(
    code_type CHARACTER VARYING,
    cd_nomenclature CHARACTER VARYING,
    id_nomenclature INTEGER,
    gnv1_pk_values CHARACTER VARYING
);

--COPY v1_compat.t_synonymes_v1 (code_type, cd_nomenclature, gnv1_pk_values) FROM '/tmp/synonyme_v1.csv' CSV DELIMITER ';';
insert into  v1_compat.t_synonymes_v1 (code_type, cd_nomenclature, gnv1_pk_values) values
	('TYP_GRP','OBS','1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28'),
	('METH_OBS','0','2,5,6,8,9,10,11,12,14,16,18,21,22,23,26,27,29,30,31,33,34,35,37,38,101,102,103,201,204,208,209,214,215,217,221,222,224,226'),
	('METH_OBS','1','4,7,207'),
	('METH_OBS','4','3,219'),
	('METH_OBS','6','205'),
	('METH_OBS','8','13,15,17,19,20,216'),
	('METH_OBS','12','211'),
	('METH_OBS','20','105,203,220'),
	('METH_OBS','23','24,25'),
	('STATUT_BIO','3','10,11,12,13,14,15,16,17,18,19,20,21,22,23,27,28,29,31,32,33,35,36,37,101,102,204,209,215,216,221,224,226'),
	('STATUT_BIO','4','26'),
	('ETAT_BIO','3','2'),
	('NAT_OBJ_GEO','St','1,2,3,4,10'),
	('NAT_OBJ_GEO','In','5,6,7,8,9,11,13,14');

UPDATE v1_compat.t_synonymes_v1 ns SET id_nomenclature=n.id_nomenclature FROM (
	SELECT n.cd_nomenclature, n.id_nomenclature, t.mnemonique
		FROM ref_nomenclatures.t_nomenclatures n
		JOIN ref_nomenclatures.bib_nomenclatures_types t
			ON t.id_type = n.id_type
)n 
WHERE ns.code_type = n.mnemonique 
	AND ns.cd_nomenclature = n.cd_nomenclature;

-- test correspondance synonymie
	SELECT n.id_type, n.cd_nomenclature, n.id_nomenclature, t.mnemonique, n.mnemonique, t.label_default, t.definition_default
		FROM ref_nomenclatures.t_nomenclatures n
		JOIN ref_nomenclatures.bib_nomenclatures_types t
			ON t.id_type = n.id_type			
	Order by t.mnemonique, n.mnemonique;

--DROP FUNCTION IF EXISTS v1_compat.get_synonyme_id_nomenclature;
--CREATE OR REPLACE FUNCTION v1_compat.get_synonyme_id_nomenclature(code_type_in text, gnv1_pk_value integer) RETURNS INTEGER
--IMMUTABLE
--LANGUAGE plpgsql AS
--$$
--DECLARE id_nomenclature_out text;
--  BEGIN 
--  SELECT INTO id_nomenclature_out id_nomenclature 
--	FROM v1_compat.t_synonymes_v1
--    	WHERE gnv1_pk_value::text = ANY(STRING_TO_ARRAY(gnv1_pk_values, ','))
--		AND code_type = code_type_in
--;
--return id_nomenclature_out;
--  END;
--$$;


-- select id_lot, v1_compat.get_synonyme_id_nomenclature('TYP_GRP', id_lot)
-- from v1_compat.bib_lots;