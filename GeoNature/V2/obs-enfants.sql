-- Renvoyer les observations des taxons enfants
-- Voir pour plutôt utiliser directement "taxonomie.find_all_taxons_children()" ?

select * from gn_synthese.synthese where cd_nom in (
WITH RECURSIVE descendants AS (
        SELECT tx1.cd_nom FROM taxonomie.taxref tx1 WHERE tx1.cd_sup = 187305
      UNION ALL
      SELECT tx2.cd_nom FROM descendants d JOIN taxonomie.taxref tx2 ON tx2.cd_sup = d.cd_nom
      )
  SELECT * FROM descendants);
