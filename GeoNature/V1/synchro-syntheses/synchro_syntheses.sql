--Refresh de la vue matérialisée contenant la synthese PNE 
REFRESH MATERIALIZED VIEW CONCURRENTLY synthesepne.vm_syntheseff ;

-- mise à jour de la synthèse locale avec le delta depuis le dernier refresh.
-- requête pour les nouvelles données
WITH ls AS (SELECT last_sync FROM synthese.t_synchronisations WHERE id_source = 9)
INSERT INTO synthese.syntheseff (
  id_source,
  id_fiche_source,
  code_fiche_source,
  id_organisme,
  id_protocole,
  id_precision,
  cd_nom,
  insee,
  dateobs,
  observateurs,
  determinateur,
  altitude_retenue,
  remarques,
  date_insert,
  date_update,
  derniere_action,
  supprime,
  the_geom_point,
  id_lot,
  id_critere_synthese,
  the_geom_3857,
  effectif_total,
  the_geom_local,
  diffusable
)
SELECT
  9 AS id_source,
  id_synthese::character varying(50) AS id_fiche_source,
  code_fiche_source,
  2 AS id_organisme,
  9 AS id_protocole,
  id_precision,
  cd_nom,
  insee,
  dateobs,
  observateurs,
  determinateur,
  altitude_retenue,
  remarques,
  now() AS date_insert,
  date_update,
  'c' AS derniere_action,
  supprime,
  the_geom_point,
  9 AS id_lot,
  id_critere_synthese,
  the_geom_3857,
  effectif_total,
  the_geom_local,
  diffusable
  FROM synthesepne.vm_syntheseff s, ls WHERE date_insert > ls.last_sync
  RETURNING id_synthese;

-- requête pour les données modifiées
WITH 
ls AS (SELECT last_sync FROM synthese.t_synchronisations WHERE id_source = 9)
,new_update AS(SELECT * FROM synthesepne.vm_syntheseff s, ls WHERE s.date_update > ls.last_sync)
UPDATE synthese.syntheseff 
SET
  code_fiche_source = n.code_fiche_source,
  id_precision = n.id_precision,
  cd_nom = n.cd_nom,
  insee = n.insee,
  dateobs = n.dateobs,
  observateurs = n.observateurs,
  determinateur = n.determinateur,
  altitude_retenue = n.altitude_retenue,
  remarques = n.remarques,
  date_insert = n.date_insert,
  date_update = now(),
  derniere_action = 'u',
  supprime = n.supprime,
  the_geom_point = n.the_geom_point,
  id_critere_synthese = n.id_critere_synthese,
  the_geom_3857 = n.the_geom_3857,
  effectif_total = n.effectif_total,
  the_geom_local = n.the_geom_local,
  diffusable = n.diffusable
  FROM new_update n
  WHERE synthese.syntheseff.id_fiche_source = n.id_synthese::character varying(50)
  AND synthese.syntheseff.id_source = 9
  RETURNING synthese.syntheseff.id_synthese;

  --Mise à jour de la date et heure de la dernière synchronisation (=maintenant)
  UPDATE synthese.t_synchronisations SET last_sync = now()  WHERE id_source = 9 RETURNING last_sync AS "synthesepne last_sync";

  --------------------
  --AUTRES SYNTHESES--
  --------------------

  -- Vous pouvez copier coller les requêtes sql ci-dessus en les adaptant 
  -- pour une autre source issue de la synthese du GeoNature (V1) d'un autre organisme.
  -- Ce script sql est lancé par le script synchro_syntheses.sh qui est lui même exécuté 2 fois par jour 
  -- (voir le crontab de l'utilisateur root en lançant la commande "sudo crontab -e")