---insertion des cd_nom manquants
WITH cd_nom_manquants AS (
SELECT DISTINCT o.cd_nom 
     FROM export_oo.saisie_observation o 
     LEFT JOIN taxonomie.taxref t ON t.cd_nom = o.cd_nom
     LEFT JOIN export_oo.t_taxonomie_synonymes s ON s.cd_nom_invalid = o.cd_nom 
     WHERE t.cd_nom IS NULL AND s.cd_nom_valid IS NULL
)
INSERT INTO taxonomie.taxref (
regne, phylum, classe, ordre, famille, cd_nom, cd_ref, nom_complet, nom_valide, nom_vern, lb_nom
)
SELECT t_oo.regne, t_oo.phylum, t_oo.classe, t_oo.ordre, t_oo.famille, t_oo.cd_nom::int, t_oo.cd_ref::int, t_oo.nom_complet, t_oo.nom_valide, COALESCE(t_oo.nom_vern, t_oo.nom_complet), t_oo.lb_nom
FROM cd_nom_manquants cm
JOIN  inpn.taxref t_oo
	ON t_oo.cd_nom::int = cm.cd_nom
LEFT JOIN taxonomie.taxref t_gn
	ON t_gn.cd_nom = t_oo.cd_nom::int
WHERE t_gn.cd_nom IS NULL
