-- clean data


-- occtax

 DELETE FROM pr_occtax.cor_role_releves_occtax;
 DELETE FROM pr_occtax.cor_counting_occtax;
 DELETE FROM pr_occtax.t_occurrences_occtax;
 DELETE FROM pr_occtax.t_releves_occtax;


-- meta

DELETE FROM gn_commons.cor_module_dataset;
DELETE FROM gn_meta.cor_dataset_actor;
DELETE FROM gn_meta.t_datasets;
DELETE FROM gn_meta.t_acquisition_frameworks;
DELETE FROM gn_meta.sinp_datatype_protocols WHERE id_protocol > 0;


-- taxonomie

DELETE FROM taxonomie.cor_nom_liste;
DELETE FROM taxonomie.bib_listes;
DELETE FROM taxonomie.bib_noms;
DELETE FROM taxonomie.taxref 
	where cd_nom >= 99900000
;


-- user
DELETE FROM utilisateurs.cor_role_liste WHERE id_role >100;
DELETE FROM utilisateurs.t_roles WHERE id_role > 100;
DELETE FROM gn_meta.cor_dataset_actor WHERE id_organism > 0;
-- on garde autre (-1) et all (0) ???
DELETE FROM utilisateurs.bib_organismes WHERE id_organisme > 0;


-- Synthese
DELETE FROM gn_synthese.t_sources;