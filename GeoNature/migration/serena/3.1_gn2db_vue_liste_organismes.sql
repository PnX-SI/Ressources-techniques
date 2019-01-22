-- #### /!\ CES REQUETES SONT A ADAPTER AU CONTEXE DE VOTRE BDD SERENA ET A LA MANIERE DONT SONT STOCKES VOS UTILISATEURS ET ORGNANISMES RATTACHES

-- On crée une vue pour lister les organismes parmi les sources de données :
CREATE OR REPLACE VIEW _import_serena.v_rnf_srce_organismes AS
SELECT DISTINCT 
	--row_number() OVER (ORDER BY (t1.srce_orga_id))::integer AS orga_id,
	t1.srce_orga_id,
	t2.srce_compnom_c as orga_nom
  FROM _import_serena.rnf_srce as t1
  LEFT JOIN _import_serena.rnf_srce as t2 ON t1.srce_orga_id = t2.srce_id
  GROUP BY t1.srce_orga_id, t2.srce_compnom_c 
  ORDER BY t1.srce_orga_id, t2.srce_compnom_c 
  ;

-- #### ATTENTION ####
-- Vérifier manuellement cette liste pour identifier d'éventuels doublons, erreurs etc.

-- Contrôler également la présence d'observateurs multiples dans le champ srce_compnom_c ou peuvent être stockés plusieurs srce_id
	--> Ce cas de figure n'est pas traité ici
-- Si le nom de l'organisme est stocké dans le champ srce_nom (exemple : "[ONF] Duchmol"), il faudra parser la chaîne de caractère pour conserer le lien entre un observateurs et son organisme de rattachement
	--> Ce cas de figure n'est pas traité ici
-- ####

  -- /!\ Dans cet exemple, on ne dispose pas de l'info d'appartenance des observateurs à des organismes 
   -- On a seulement les catégories d'utilisateurs que l'on identifie avec la requête suivante :
   SELECT DISTINCT choi_id, choi_nom
	FROM _import_serena.rnf_choi
	JOIN _import_serena.rnf_srce ON rnf_choi.choi_id = rnf_srce.srce_categ_choi_id
	ORDER BY choi_id

-- On crée une vue pour lister tous les utilisateurs (observateurs et déterminateurs) cités dans les donées d'observations
-- On choisi les champs que l'on souhaite y intégrer

	-- On utilise la requête précédente en sous-requete (WITH) 
CREATE OR REPLACE VIEW _import_serena.v_rnf_srce_utilisateurs AS
WITH srce_categ AS (
	SELECT DISTINCT choi_id, choi_nom
	FROM _import_serena.rnf_choi
	JOIN _import_serena.rnf_srce ON rnf_choi.choi_id = rnf_srce.srce_categ_choi_id
	ORDER BY choi_id
	),
	observateurs AS (
	SELECT DISTINCT s.srce_id, s.srce_nom, s.srce_prenom, s.srce_compnom_c, s.srce_categ_choi_id, c.choi_nom as srce_categ, count(o.obse_id) total_obse 
	FROM _import_serena.rnf_obse o
	JOIN _import_serena.rnf_srce s ON o.obse_obsv_id = s.srce_id
	JOIN srce_categ c ON s.srce_categ_choi_id = c.choi_id
	GROUP BY s.srce_id, s.srce_nom, s.srce_prenom, s.srce_compnom_c, s.srce_categ_choi_id, c.choi_nom 
	ORDER BY total_obse DESC, s.srce_compnom_c)
	-- Les observateurs identifiés dans les données d'observations :
(SELECT DISTINCT *
	FROM observateurs
	)
	-- Les déterminateurs identifiés dans les données d'observations MAIS, non-cité comme observateurs :
UNION
(SELECT DISTINCT s.srce_id, s.srce_nom, s.srce_prenom, s.srce_compnom_c, s.srce_categ_choi_id, c.choi_nom as srce_categ, count(o.obse_id) total_obse 
	FROM _import_serena.rnf_obse o
	JOIN _import_serena.rnf_srce s ON o.obse_detm_id = s.srce_id
	JOIN srce_categ c ON s.srce_categ_choi_id = c.choi_id
	LEFT JOIN observateurs v ON o.obse_detm_id = v.srce_id
	WHERE v.srce_id IS NULL
	GROUP BY s.srce_id, s.srce_nom, s.srce_prenom, s.srce_compnom_c, s.srce_categ_choi_id, c.choi_nom 
	ORDER BY total_obse DESC, s.srce_compnom_c
	)
;