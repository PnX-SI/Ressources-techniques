-- Récupérer tous les taxons avec une valeur d'un attribut
-- Ici les plantes avec l'attribut "Patrimonial" égal à "Oui"

SELECT *
FROM taxonomie.taxref t 
JOIN taxonomie.bib_noms bn ON bn.cd_nom = t.cd_nom 
JOIN taxonomie.cor_taxon_attribut cta ON cta.cd_ref = bn.cd_ref 
JOIN taxonomie.bib_attributs ba ON ba.id_attribut = cta.id_attribut 
WHERE ba.nom_attribut = 'patrimonial' AND cta.valeur_attribut ='oui'
AND t.regne = 'Plantae' AND t.cd_nom = t.cd_ref


-- réattribuer le bon cd_nom pour les cd_nom négatifs créés avant leur sortie dans taxref
-- requete lancé après une migration taxref sur les données de la synthese (à faire éventuellement sur d'autres tables)
update gn_synthese.synthese
set cd_nom = t.cd_nom
from taxonomie.taxref t
join (
select * 
from taxonomie.taxref t 
where cd_nom < 0
)neg on t.lb_nom ilike neg.lb_nom 
where t.cd_nom > 0 and gn_synthese.synthese.cd_nom = neg.cd_nom


-- supprimer les cd_nom négatifs inutilisé après la réattribution du bon cd_nom
delete from taxonomie.taxref 
where taxonomie.taxref.cd_nom in (
select neg.cd_nom
from taxonomie.taxref t
join (
select * 
from taxonomie.taxref t 
where cd_nom < 0
)neg on t.lb_nom ilike neg.lb_nom 
where t.cd_nom > 0
);
