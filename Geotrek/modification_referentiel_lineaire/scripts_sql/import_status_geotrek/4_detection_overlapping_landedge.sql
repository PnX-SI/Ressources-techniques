---------- Création d'une table permettant de visualiser les erreurs de landedge dans QGIS sous forme ponctuelle
CREATE TABLE IF NOT EXISTS overlapping_landedge (
    id integer PRIMARY KEY,
    geom geometry,
    supervised boolean
);

---------- Les points ne représentent pas le lieu exact de l'erreur mais seulement le core_topology reperé comme problématique
INSERT INTO overlapping_landedge (id, geom)
SELECT ct.id,
       ST_PointN(ct.geom, ST_NumPoints(ct.geom)/2) -- le point du milieu du core_topology concerné
  FROM core_topology ct
  JOIN rlesi_cartosud_updated rcu
    ON ct.kind = 'LANDEDGE'
   AND ST_Overlaps(rcu.geom, ct.geom)
   AND NOT ST_Equals(ST_Boundary(ct.geom), St_Boundary(rcu.geom)) -- on ne veut repérer que les erreurs aux extrémités de 'LANDEDGE'
 ORDER BY ct.id
    ON CONFLICT (id) -- si le core_topology est déjà présent dans la table (id identique)...
    DO NOTHING;      -- ...ne rien faire et continuer la requête
