SELECT
	t.mnemonique AS code_type,
	n.cd_nomenclature,
	n.label_default
	
FROM ref_nomenclatures.t_nomenclatures n
JOIN ref_nomenclatures.bib_nomenclatures_types t
	ON t.id_type = n.id_type
WHERE t.mnemonique = 'NIV_PRECIS'
ORDER BY n.cd_nomenclature
;

-- NIV_PRECIS

select * from ref_nomenclatures.bib_nomenclatures_types t ordeR BY mnemonique;