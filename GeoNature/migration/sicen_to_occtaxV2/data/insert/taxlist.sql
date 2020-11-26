-- mise à jour de la liste TH en fonction des données présentes dans la synthèse

INSERT INTO taxonomie.bib_noms (cd_nom, cd_ref, nom_francais)
WITH cd_nom_synthese AS (
	SELECT DISTINCT cd_nom FROM gn_synthese.synthese
)
SELECT s.cd_nom, t.cd_ref, COALESCE(t.nom_vern, t.lb_nom)
FROM cd_nom_synthese s
JOIN taxonomie.taxref t ON t.cd_nom = s.cd_nom 
LEFT JOIN taxonomie.bib_noms n ON n.cd_nom = s.cd_nom AND n.cd_ref = t.cd_ref
WHERE n.cd_nom IS NULL and n.cd_ref IS NULL
;

INSERT INTO taxonomie.cor_nom_liste (id_liste, id_nom)
SELECT l.id_liste, n.id_nom 
	FROM taxonomie.bib_noms n
	JOIN taxonomie.bib_listes l
	  ON l.nom_liste = 'Saisie Occtax'
	LEFT JOIN taxonomie.cor_nom_liste c
	  ON c.id_nom = n.id_nom
	WHERE c.id_nom IS NULL
;