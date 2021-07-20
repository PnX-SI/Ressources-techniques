-- clean data


-- occtax

DELETE FROM pr_occtax.cor_role_releves_occtax;
DELETE FROM pr_occtax.cor_counting_occtax;
DELETE FROM pr_occtax.t_occurrences_occtax;
DELETE FROM pr_occtax.t_releves_occtax;

-- Synthese
DELETE FROM gn_synthese.synthese;
DELETE FROM gn_synthese.t_sources WHERE name_source != 'Occtax';


-- meta
DELETE FROM gn_commons.cor_module_dataset;
DELETE FROM gn_meta.cor_acquisition_framework_voletsinp;
DELETE FROM gn_meta.cor_acquisition_framework_objectif;
DELETE FROM gn_meta.cor_acquisition_framework_actor;
DELETE FROM gn_meta.cor_dataset_actor;
DELETE FROM gn_meta.t_datasets;
DELETE FROM gn_meta.t_acquisition_frameworks;
DELETE FROM gn_meta.sinp_datatype_protocols WHERE id_protocol > 0;


-- taxonomie

DELETE from taxonomie.import_taxref;
DELETE FROM taxonomie.cor_nom_liste;
DELETE FROM taxonomie.bib_listes ;
DELETE FROM taxonomie.bib_noms ;
DELETE FROM taxonomie.taxref WHERE cd_nom >= 99900000 or cd_nom in (965424, 926098);


-- user
DELETE FROM utilisateurs.cor_roles;
DELETE FROM utilisateurs.cor_role_liste;
DELETE FROM utilisateurs.t_roles WHERE id_role >= 10 or id_role = 8;
UPDATE utilisateurs.t_roles SET id_organisme = -1;
DELETE FROM gn_meta.cor_dataset_actor WHERE id_organism > 0;
DELETE FROM utilisateurs.bib_organismes WHERE id_organisme > 0;

--- Les tables d'import de data

DROP TABLE if exists gn_imports.t_releves_basephotoseb ;
DROP TABLE if exists gn_imports.t_occurrences_basephotoseb ;
DROP TABLE if exists gn_imports.cor_counting_basephotoseb ;
DROP TABLE if exists gn_imports.t_medias_basephotoseb;
DROP TABLE if exists gn_imports.t_releves_cardobsseb;
DROP TABLE if exists gn_imports.t_occurrences_cardobsseb;
DROP TABLE if exists gn_imports.cor_counting_cardobsseb;
DROP TABLE if exists gn_imports.tmp_localitespoly_seb ;
DROP TABLE if exists gn_imports.tmp_localiteslignes_seb ;
DROP TABLE if exists gn_imports.tmp_localitespoints_seb ;
DROP TABLE if exists gn_imports.synthese_FGJuin2021 ;
DROP TABLE if exists gn_imports.synthese_herbierJuin2021 ;
DROP TABLE if exists gn_imports.tmp_localitespoly_ecobios ;
DROP TABLE if exists gn_imports.synthese_EcobiosLimonade ;
DROP TABLE if exists gn_imports.synthese_malaco;
DROP TABLE if exists gn_imports.synthese_inaturalist ;
DROP TABLE if exists gn_imports.synthese_cumul_data ;
