-- Récupérer tous les taxons avec une valeur d'un attribut
-- Ici les plantes avec l'attribut "Patrimonial" égal à "Oui"

SELECT *
FROM taxonomie.taxref t 
JOIN taxonomie.bib_noms bn ON bn.cd_nom = t.cd_nom 
JOIN taxonomie.cor_taxon_attribut cta ON cta.cd_ref = bn.cd_ref 
JOIN taxonomie.bib_attributs ba ON ba.id_attribut = cta.id_attribut 
WHERE ba.nom_attribut = 'patrimonial' AND cta.valeur_attribut ='oui'
AND t.regne = 'Plantae' AND t.cd_nom = t.cd_ref
