-- Import des attributs et ajout de la source pour Description et Commentaire

SELECT cor_taxon_attribut.cd_ref,
    cor_taxon_attribut.id_attribut,
    CASE WHEN (cor_taxon_attribut.id_attribut = 100) OR (cor_taxon_attribut.id_attribut = 101) THEN CONCAT(cor_taxon_attribut.valeur_attribut,' <i>Source : Parc national des Ecrins</i>')
    ELSE cor_taxon_attribut.valeur_attribut
    END AS value
   FROM taxonomie.cor_taxon_attribut
  WHERE cor_taxon_attribut.id_attribut = ANY (ARRAY[100, 101, 102, 103])
  ORDER BY cor_taxon_attribut.cd_ref
