-- On crée une VM basé sur la liste des espèces présentes dans la région du territoire concerné (ici Rhône-Alpes) à partir d'un export téléchargé sur le site de l'INPN
-- Cette VM contient :
-- les taxons + leurs synonymes + leurs taxons de rangs supérieurs (on conserve cette dernière info dans un champs 'codes_taxsup' qui aggrège dans un tableau tous les cd_nom des taxons de rang supérieur pour chaque taxon de référence)
-- On en profite pour calculer les champs 'protege' (true si cité dans un articles de protection qui concerne mon territoire) et 'saisie_possible' (true si taxon de référence) 

CREATE MATERIALIZED VIEW _import_serena.vm_bib_noms_inpn
AS
SELECT DISTINCT
		t2.regne,
		t2.classe,
		t2.ordre,
		t2.famille,
		t2.group1_inpn,
		t2.group2_inpn,
		t2.cd_nom,
		t2.cd_ref,
		t2.lb_nom,
		t2.nom_vern,
		t2.cd_sup,
		t2.id_rang,
    	max(('{'::text || concat_ws(','::text, t3.cd_nom, t4.cd_nom, t5.cd_nom, t6.cd_nom, t7.cd_nom, t8.cd_nom, t9.cd_nom, t10.cd_nom, t11.cd_nom)) || '}'::text)::integer[] AS codes_taxsup,
        	CASE
         	   WHEN t2.cd_nom = t2.cd_ref THEN true
         	   ELSE false
      	  END AS saisie_possible,
   		 bool_or(
       		CASE
            	WHEN p0.cd_protection IS NOT NULL OR p2.cd_protection IS NOT NULL THEN true
            	ELSE false
        	END) AS protege
	FROM taxonomie.taxref t2
	 JOIN _ref_inpn_listes.inpn_liste_especes_rhone_alpes b ON t2.cd_ref = b.cd_ref
	 -- Jointures sur les articles de protections des espèces pour identifier les taxons protégés
	 LEFT JOIN taxonomie.taxref_protection_especes p ON t2.cd_nom = p.cd_nom
	 LEFT JOIN taxonomie.taxref_protection_articles_structure p0 ON (p.cd_protection = p0.cd_protection AND p0.alias_statut ILIKE 'protection' AND p0.concerne_structure IS TRUE)
	 -- Jointures cascadées pour récupérer les cd_nom des taxons de rang supérieurs (pour les proposer à la saisie par exemple)
     LEFT JOIN taxonomie.taxref t3 ON t2.cd_sup = t3.cd_nom
     LEFT JOIN taxonomie.taxref t4 ON t3.cd_sup = t4.cd_nom
     LEFT JOIN taxonomie.taxref t5 ON t4.cd_sup = t5.cd_nom
     LEFT JOIN taxonomie.taxref t6 ON t5.cd_sup = t6.cd_nom
     LEFT JOIN taxonomie.taxref t7 ON t6.cd_sup = t7.cd_nom
     LEFT JOIN taxonomie.taxref t8 ON t7.cd_sup = t8.cd_nom
     LEFT JOIN taxonomie.taxref t9 ON t8.cd_sup = t9.cd_nom
     LEFT JOIN taxonomie.taxref t10 ON t9.cd_sup = t10.cd_nom
     LEFT JOIN taxonomie.taxref t11 ON t10.cd_sup = t11.cd_nom
     -- Jointures sur les articles de protections des espèces pour identifier les taxons protégés EN TENANT COMPTE DES TAXONS DE RANGS SUPERIEURS traités ci-dessus
     LEFT JOIN taxonomie.taxref_protection_especes p1 ON p1.cd_nom = ANY (((('{'::text || concat_ws(','::text, t3.cd_nom, t4.cd_nom, t5.cd_nom, t6.cd_nom, t7.cd_nom, t8.cd_nom, t9.cd_nom, t10.cd_nom, t11.cd_nom)) || '}'::text)::integer[]))
  	 LEFT JOIN taxonomie.taxref_protection_articles_structure p2 ON (p1.cd_protection = p2.cd_protection AND p2.alias_statut ILIKE 'protection' AND p2.concerne_structure IS TRUE)
  GROUP BY t2.cd_nom, t2.cd_ref, t2.lb_nom, t2.nom_vern, t2.regne, t2.classe, t2.ordre, t2.famille, t2.group1_inpn, t2.group2_inpn, t2.id_rang, t2.cd_sup
  ORDER BY t2.regne, t2.classe, t2.ordre, t2.famille, t2.group1_inpn, t2.group2_inpn, t2.cd_ref, t2.lb_nom, t2.nom_vern, t2.cd_nom, t2.id_rang, t2.cd_sup
WITH DATA ;

ALTER TABLE _import_serena.vm_bib_noms_inpn
  OWNER TO geonatadmin;
  
CREATE UNIQUE INDEX i_unique_cd_nom_vm_bib_noms_inpn
  ON  _import_serena.vm_bib_noms_inpn
  USING btree
  (cd_nom);

/*  
-- Sélection des taxons valides présents dans la liste des espèces (cd_ref) de région RA de l'INPN et absents des données du territoire
SELECT DISTINCT 
		b.group2_inpn, 
		--b.cd_nom as cd_nom_inpn, 
		b.cd_ref as cd_ref_inpn,
		array_agg(b.lb_nom) as noms
FROM _import_serena.vm_bib_noms_inpn b 
LEFT JOIN _import_serena.vm_obs_serena_detail_point a ON b.cd_nom = a.taxo_mnhn_id
WHERE a.taxo_mnhn_id IS NULL
GROUP BY b.group2_inpn, b.cd_ref
;

-- On compare cette liste aux espèces observées dans les JDD agrégés du Territoire 
-- Ceci afin d'identifier les taxons observés n'étant pas cités dans la liste des espèces de région RA issue de l'INPN
SELECT DISTINCT 
		t.group2_inpn, 
		a.taxo_mnhn_id as cd_nom,
		t.cd_ref,
		t.lb_nom,
		t.nom_vern,
		t.id_rang,
		b.cd_nom
FROM  _import_serena.vm_obs_serena_detail_point a 
LEFT JOIN taxonomie.taxref t ON a.taxo_mnhn_id = t.cd_nom
LEFT JOIN _import_serena.vm_bib_noms_inpn b ON a.taxo_mnhn_id = b.cd_nom
WHERE b.cd_nom IS NULL
AND a.taxo_mnhn_id = t.cd_ref
;
