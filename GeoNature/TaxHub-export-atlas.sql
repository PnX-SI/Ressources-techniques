-- Export des attributs de l'atlas et ajout de la source pour Description et Commentaire

SELECT 
    cor_taxon_attribut.cd_ref,
    cor_taxon_attribut.id_attribut,
       CASE WHEN (cor_taxon_attribut.id_attribut = 100) OR (cor_taxon_attribut.id_attribut = 101) THEN CONCAT(cor_taxon_attribut.valeur_attribut,' <i>Source : Parc national des Ecrins</i>')
       ELSE cor_taxon_attribut.valeur_attribut
    END AS value
   FROM taxonomie.cor_taxon_attribut
  WHERE cor_taxon_attribut.id_attribut = ANY (ARRAY[100, 101, 102, 103])
  ORDER BY cor_taxon_attribut.cd_ref, cor_taxon_attribut.id_attribut;

-- Export des photos de taxons du PNE

CREATE OR REPLACE VIEW gn_exports.v_photos_pne
AS SELECT m.cd_ref,
    t.nom_valide AS nom_taxon,
    t.nom_vern,
    m.id_media AS id_media_pne,
    'https://geonature.ecrins-parcnational.fr/api/media/taxhub/'::text || m.chemin::text AS url_pne,
    m.titre AS titre_media,
    m.auteur AS auteur_media
   FROM taxonomie.t_medias m
     RIGHT JOIN taxonomie.taxref t ON t.cd_nom = m.cd_ref
  WHERE m.id_type = 1 OR m.id_type = 2 AND m.url IS NULL AND (m.auteur::text ~~* '%PNE%'::text OR unaccent(m.auteur::text) ~~* unaccent('%Parc national des Ecrins%'::text))
  ORDER BY m.cd_ref;
