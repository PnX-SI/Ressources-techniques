-- Export de toutes les données d'un JDD ('47' dans notre cas)
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

-- Export de toutes les données d'une classe
SELECT 
 e.* 
FROM gn_synthese.v_synthese_for_export e
 JOIN taxonomie.taxref t ON t.cd_nom = e."cdNom"
WHERE t.classe = 'Chilopoda'
ORDER by "dateDebut"

-- Export des données d'une classe dans 2 communes
-- Retrouver les id_area des communes
SELECT * FROM ref_geo.li_municipalities
WHERE nom_com ILIKE '%Jean%';
-- Rechercher les observations d'oiseaux dans ces 2 communes
SELECT DISTINCT ON (e."idSynthese") "idSynthese",
 e.*
-- , ST_astext(thegeom)
FROM gn_synthese.v_synthese_for_export e
-- JOIN gn_synthese.cor_area_synthese c ON c.id_synthese = e."idSynthese"
-- JOIN taxonomie.taxref t ON t.cd_nom = e."cdNom"
-- WHERE t.group2inpn = 'Oiseaux'
-- WHERE e.classe = 'Aves'
-- WHERE c.id_area IN (28221,4305) -- Limiter à 2 communes
WHERE "idSynthese" IN (Select Distinct id_synthese FROM gn_synthese.cor_area_synthese c WHERE c.id_area IN (28221,4305))
AND e.classe = 'Aves'
ORDER by e."idSynthese";
