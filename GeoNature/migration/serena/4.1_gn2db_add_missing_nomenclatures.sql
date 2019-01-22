/* Dans la table t_nomenclatures telle qu'importée lors de l'install de GN2, il manque 2 types de nomenclatures et leurs valeurs : confidentialité et sociabilité
	On récupère dans le référentiel de nomenclatures du SINP (http://standards-sinp.mnhn.fr/nomenclature/) les tables concernées 
	On les intègre ensuite manuellement dans la BDD de GN2 (ici dans _imports.inpn_nomenclature_sociab et _imports.inpn_nomenclature_confid)
	Puis, on les insert manuellement dans la table t_nomenclatures en prenant soin de reporter correctement leur id_type respectif (bib_nomenclatures_types) dans la requête suivante :
*/
INSERT INTO ref_nomenclatures.t_nomenclatures(
	id_type, cd_nomenclature, mnemonique, label_default, definition_default, label_fr, definition_fr, source, statut, id_broader, hierarchy, meta_create_date, meta_update_date, active)
	SELECT '72', code, mnemonique, libelle, definition, libelle, definition, 'SINP', 'Validé', 0, '072'||'.'||concat(0,0,code), now(), now(), true
	FROM _imports.inpn_nomenclature_sociab
	;
INSERT INTO ref_nomenclatures.t_nomenclatures(
	id_type, cd_nomenclature, mnemonique, label_default, definition_default, label_fr, definition_fr, source, statut, id_broader, hierarchy, meta_create_date, meta_update_date, active)
	SELECT '31', code, mnemonique, libelle, definition, libelle, definition, 'SINP', 'Validé', 0, '031'||'.'||concat(0,0,code), now(), now(), true
	FROM _imports.inpn_nomenclature_confid
	;