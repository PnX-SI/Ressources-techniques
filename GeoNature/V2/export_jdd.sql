-- Export de toutes les données d'un JDD (47 dans notre cas)

SELECT 
  t.nom_valide, 
  t.nom_vern, 
  regne,
  phylum,
  classe,
  ordre,
  famille,
  group1_inpn,
  group2_inpn,
  e.* 
FROM gn_synthese.v_synthese_for_export e
JOIN taxonomie.taxref t ON t.cd_nom = e."cdNom"
WHERE "jddId" = 47;
