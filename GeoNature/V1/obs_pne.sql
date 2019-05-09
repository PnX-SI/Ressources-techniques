-- Lister toutes les observations du PNE diffusables (- 2 espèces sensibles)

SELECT s.id_synthese AS id_observation,
    s.dateobs,
    s.observateurs,
    u.nom_organisme AS organisme,
    l.nom_lot AS jdd_source,
    s.altitude_retenue AS altitude,
    s.insee,
    CASE
        WHEN s.effectif_total = 0 THEN NULL -- Si effectif 0 alors laisser vide
        ELSE s.effectif_total
      END AS effectif,
    s.cd_nom,
    tx.cd_ref,
    tx.lb_nom,
    tx.nom_vern,
    tx.regne,
    tx.phylum,
    tx.classe,
    tx.ordre,
    tx.famille,
    tx.group2_inpn,
    p.nom_precision AS precision_obs,
    s.the_geom_point,
    st_asgeojson(st_transform(st_setsrid(s.the_geom_point, 3857), 4326)) AS geojson_point
   FROM synthese.syntheseff s
     LEFT JOIN taxonomie.taxref tx ON tx.cd_nom = s.cd_nom
     LEFT JOIN utilisateurs.bib_organismes u ON u.id_organisme = s.id_organisme
     LEFT JOIN meta.bib_lots l ON l.id_lot = s.id_lot
     LEFT JOIN meta.t_precisions p ON p.id_precision = s.id_precision
     -- Intersection à adapter si on veut limiter à un zonage
     -- JOIN atlas.t_layer_territoire m ON st_intersects(m.the_geom, s.the_geom_point)
  WHERE s.supprime = false AND s.diffusable = true AND (tx.cd_ref <> ALL (ARRAY[18437, 94041])) AND s.id_organisme = 2
  -- LIMIT 100
