------------------------------------------------------------------------------------------------
-- Supprimer une observation dans la synthèse et sa table source à partir de son UUID (ou autre)
------------------------------------------------------------------------------------------------

-- Retrouver la donnée dans la synthèse et vérifier ses informations essentielles
SELECT * FROM gn_synthese.synthese s 
WHERE unique_id_sinp = '8872a254-b17e-4333-ac3b-e6b33611938f';
-- id_synthese=1173907
-- id_source=200
-- entity_source_pk_value=341
-- cd_nome=163333
-- date_min = 2016-05-22 00:00:00

-- Retrouver la table source de la donnée
SELECT * FROM gn_synthese.t_sources
WHERE id_source = 200;
-- hist_embrun2016.embrun_2016.gid

SELECT * FROM hist_embrun2016.embrun_2016
WHERE gid=341;
-- cd_nom=16333
-- dateobs=2016-05-22

-- Supprimer la donnée de la table source
DELETE FROM hist_embrun2016.embrun_2016
WHERE gid=341;

-- Supprimer la donnée de la synthèse
DELETE FROM gn_synthese.synthese s 
WHERE unique_id_sinp = '8872a254-b17e-4333-ac3b-e6b33611938f';
