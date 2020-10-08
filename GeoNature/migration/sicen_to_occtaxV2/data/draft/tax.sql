SELECT DISTINCT oo.cd_nom, oo.nom_cite 
	FROM export_oo.t_occurrences_occtax oo
	LEFT JOIN taxonomie.taxref t
		ON t.cd_nom = oo.cd_nom
	WHERE t.cd_nom IS NULL