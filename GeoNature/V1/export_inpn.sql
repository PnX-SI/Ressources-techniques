-- Requête permettant d'exporter les données du PNE présentes dans la synthèse pour un envoi INPN
-- On exporte toutes les données du PNE brutes, sans dégradation
-- Pour cet export basique on se base uniquement sur la géométrie ponctuelle (centroïde quand la géométrie source est ligne ou polygone)

SELECT s.id_synthese AS id_obs_pne,
    s.dateobs,
    s.observateurs,
    u.nom_organisme AS organisme,
    --l.nom_lot AS jdd_source,
    s.altitude_retenue AS altitude,
    c.nom_critere_synthese AS critere,
    CASE
        WHEN s.effectif_total = 0 THEN NULL -- Si effectif 0 alors laisser vide
        ELSE s.effectif_total
    END AS effectif,
    s.cd_nom,
    tx.cd_ref,
    tx.lb_nom,
    tx.nom_vern,
    s.remarques,
    s.date_insert,
    s.date_update,
    s.diffusable,
    st_x(st_transform(s.the_geom_point,4326)) AS x_4326,
    st_y(st_transform(s.the_geom_point,4326)) AS y_4326
   FROM synthese.syntheseff s
     LEFT JOIN taxonomie.taxref tx ON tx.cd_nom = s.cd_nom
     LEFT JOIN utilisateurs.bib_organismes u ON u.id_organisme = s.id_organisme
     LEFT JOIN meta.bib_lots l ON l.id_lot = s.id_lot
     LEFT JOIN synthese.bib_criteres_synthese c ON c.id_critere_synthese = s.id_critere_synthese
     LEFT JOIN meta.t_precisions p ON p.id_precision = s.id_precision
     -- JOIN atlas.t_layer_territoire m ON st_intersects(m.the_geom, s.the_geom_point)
  WHERE s.supprime = false AND s.id_organisme = 2 AND s.cd_nom > 0;
