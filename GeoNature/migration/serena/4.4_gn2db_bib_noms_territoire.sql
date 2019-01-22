/* 
Sélection de tous les taxons observés dans la vue mat. _import_serena.vm_obs_serena_detail_point  + tous leurs synonymes et ajout de 4 champs :
- codes_taxsup::integer[] => ARRAY qui compile les cd_nom de rang supérieur (utile pour calcul si taxon protégé)
- saisie_possible::boolean => valeur TRUE si cd_nom = cd_ref
- protege::boolean => TRUE si cd_nom cité dans la table taxonomie.taxref_protection_especes + cd_protection cité dans la table taxonomie.taxref_protection_articles + type_protection LIKE 'Protection' + concerne_mon_territoire IS TRUE
- patrimonial::boolean => FALSE par défaut. Renseigner TRUE manuellement si le taxon est patrimonial (uniquement celui dont le cd_nom = cd_ref -> on automatisera ensuite la répercution sur tous les synonymes)

/!\ Il est nécessaire d'identifier les articles de protection/réglementation dans la table taxonomie.taxref_protection_articles PUIS de peupler la table taxonomie.taxref_protection_articles_structures en conséquence
*/

--DROP MATERIALIZED VIEW _import_serena.vm_bib_noms_territoire;
CREATE MATERIALIZED VIEW _import_serena.vm_bib_noms_territoire AS

SELECT DISTINCT t2.regne, t2.classe, t2.ordre, t2.famille, t2.group1_inpn, t2.group2_inpn, t2.cd_nom, t2.cd_ref, t2.lb_nom, t2.nom_vern,
    t2.cd_sup, t2.id_rang,
    max('{'|| concat_ws(',', t3.cd_nom, t4.cd_nom, t5.cd_nom, t6.cd_nom, t7.cd_nom, t8.cd_nom, t9.cd_nom, t10.cd_nom, t11.cd_nom)||'}')::integer[] as codes_taxsup,
    CASE WHEN t2.cd_nom = t2.cd_ref THEN TRUE ELSE FALSE END::boolean AS saisie_possible,
    bool_or(CASE WHEN (p0.cd_protection IS NOT NULL OR p2.cd_protection IS NOT NULL) THEN TRUE ELSE FALSE END)::boolean AS protege, 
    max(a.date) as last_date_obs, 
    count(a.obse_id) as nbre_obs
  FROM _import_serena.vm_obs_serena_detail_point a
  -- Jointure Taxref sur le cd_nom
  JOIN taxonomie.taxref t1 ON a.taxo_mnhn_id = t1.cd_nom 
  -- Jointure Taxref sur le taxon de référence (cd_ref) pour gérer la synonymie
  JOIN taxonomie.taxref t2 ON t1.cd_ref = t2.cd_ref 
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
  LEFT JOIN taxonomie.taxref_protection_especes p1 ON p1.cd_nom = ANY (cast(('{'|| concat_ws(',', t3.cd_nom, t4.cd_nom, t5.cd_nom, t6.cd_nom, t7.cd_nom, t8.cd_nom, t9.cd_nom, t10.cd_nom, t11.cd_nom)||'}') AS integer[]))
  LEFT JOIN taxonomie.taxref_protection_articles_structure p2 ON (p1.cd_protection = p2.cd_protection AND p2.alias_statut ILIKE 'protection' AND p2.concerne_structure IS TRUE)

  GROUP BY  t2.cd_nom, t2.cd_ref, t2.lb_nom, t2.nom_vern, t2.regne, t2.classe, t2.ordre, t2.famille, t2.group1_inpn, t2.group2_inpn, t2.id_rang, t2.cd_sup
  ORDER BY t2.regne, t2.classe, t2.ordre, t2.famille, t2.group1_inpn, t2.group2_inpn, t2.cd_ref, t2.lb_nom, t2.nom_vern, t2.cd_nom, t2.id_rang, t2.cd_sup

WITH DATA ; 

ALTER TABLE _import_serena.vm_bib_noms_territoire
  OWNER TO geonatadmin;
  
CREATE UNIQUE INDEX i_unique_cd_nom_vm_bib_noms_territoire
  ON _import_serena.vm_bib_noms_territoire
  USING btree
  (cd_nom);
