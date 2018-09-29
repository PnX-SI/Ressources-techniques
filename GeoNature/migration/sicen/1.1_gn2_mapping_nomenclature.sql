---obs_methode -> determination 

SELECT id_type, cd_nomenclature, mnemonique, label_default, initial_value, 
       id_nomenclature
  FROM ref_nomenclatures.t_synonymes
  ORDER BY id_type;

INSERT INTO ref_nomenclatures.t_synonymes (id_type, initial_value)
SELECT DISTINCT 14, determination
  FROM import_obs_occ.fdw_obs_occ_data;

UPDATE ref_nomenclatures.t_synonymes s SET id_nomenclature = t.id_nomenclature
FROM ref_nomenclatures.t_nomenclatures t
WHERE s.initial_value ilike t.label_default AND s.id_type = 14 and t.id_type = 14;


UPDATE ref_nomenclatures.t_synonymes s SET id_nomenclature = t.id_nomenclature
FROM ref_nomenclatures.t_nomenclatures t
WHERE t.id_type = 7 AND s.id_type = 7 AND t.cd_nomenclature = '20' AND s.initial_value IN ('Indice de présence', 'Cadavre',  'Capture', 'Piège photographique');

-- occ_etat_biologique -> determination

INSERT INTO ref_nomenclatures.t_synonymes (id_type, initial_value)
SELECT DISTINCT 7, determination
  FROM import_obs_occ.fdw_obs_occ_data;

UPDATE ref_nomenclatures.t_synonymes s SET id_nomenclature = t.id_nomenclature
FROM ref_nomenclatures.t_nomenclatures t
WHERE t.id_type = 7 AND s.id_type = 7 AND t.cd_nomenclature = '2' AND s.initial_value IN ('Vu',  'Entendu', 'Capture', 'Piège photographique');

UPDATE ref_nomenclatures.t_synonymes s SET id_nomenclature = t.id_nomenclature
FROM ref_nomenclatures.t_nomenclatures t
WHERE t.id_type = 7 AND s.id_type = 7 AND t.cd_nomenclature = '0' AND s.initial_value IN ('Indice de présence');

UPDATE ref_nomenclatures.t_synonymes s SET id_nomenclature = t.id_nomenclature
FROM ref_nomenclatures.t_nomenclatures t
WHERE t.id_type = 7 AND s.id_type = 7 AND t.cd_nomenclature = '3' AND s.initial_value IN ('Cadavre');



-- occ_sexe -> phenologie

INSERT INTO ref_nomenclatures.t_synonymes (id_type, initial_value)
SELECT DISTINCT 9, phenologie
  FROM import_obs_occ.fdw_obs_occ_data;


UPDATE ref_nomenclatures.t_synonymes s SET id_nomenclature = t.id_nomenclature
FROM ref_nomenclatures.t_nomenclatures t
WHERE s.initial_value ilike t.label_default AND s.id_type = 9 and t.id_type = 9;

UPDATE ref_nomenclatures.t_synonymes s SET id_nomenclature = t.id_nomenclature
FROM ref_nomenclatures.t_nomenclatures t
WHERE t.id_type = 9 AND s.id_type = 9 AND t.cd_nomenclature = '5' AND s.initial_value IN ('Couple', 'Mâle et femelle');



-- occ_stade_de_vie -> type_effectif

INSERT INTO ref_nomenclatures.t_synonymes(
            id_type, initial_value
)
SELECT DISTINCT 10, type_effectif
FROM import_obs_occ.fdw_obs_occ_data
WHERE NOT type_effectif IS NULL AND NOT type_effectif =''
 

UPDATE  ref_nomenclatures.t_synonymes a SET id_nomenclature = t.id_nomenclature
FROM ref_nomenclatures.t_nomenclatures t
WHERE t.id_type = a.id_type and lower(initial_value) = lower(t.label_default)
AND a.id_nomenclature IS NULL;

UPDATE   ref_nomenclatures.t_synonymes a SET cd_nomenclature = '6'
WHERE initial_value = 'Chenille/larve';

UPDATE   ref_nomenclatures.t_synonymes a SET cd_nomenclature = '9'
WHERE initial_value = 'Oeuf/ponte';

UPDATE   ref_nomenclatures.t_synonymes a SET cd_nomenclature = 7
WHERE initial_value = 'Chenille/larve';


-- statut de validation

INSERT INTO ref_nomenclatures.t_synonymes(
            id_type, initial_value
)
SELECT DISTINCT 101, statut_validation::text
FROM import_obs_occ.fdw_obs_occ_data;


UPDATE   ref_nomenclatures.t_synonymes s SET id_nomenclature = t.id_nomenclature 
FROM ref_nomenclatures.t_nomenclatures t
WHERE initial_value = 'validée' AND t.cd_nomenclature = '1' AND t.id_type = 101 AND s.id_type = 101 ;

UPDATE   ref_nomenclatures.t_synonymes s SET id_nomenclature = t.id_nomenclature
FROM ref_nomenclatures.t_nomenclatures t
WHERE initial_value = 'à valider' AND t.cd_nomenclature = '0' AND t.id_type = 101 AND s.id_type = 101 ;

UPDATE   ref_nomenclatures.t_synonymes s SET id_nomenclature = t.id_nomenclature
FROM ref_nomenclatures.t_nomenclatures t
WHERE initial_value = 'non valide' AND t.cd_nomenclature = '4' AND t.id_type = 101 AND s.id_type = 101 ;


---NETTOYAGE

ALTER TABLE  ref_nomenclatures.t_synonymes  ADD id serial PRIMARY KEY;
DELETE
 FROM ref_nomenclatures.t_synonymes l
 USING ref_nomenclatures.t_synonymes r
WHERE l.id < r.id AND l.id_nomenclature = r.id_nomenclature AND l.initial_value = r.initial_value


DELETE FROM ref_nomenclatures.t_synonymes  WHERE initial_value IS NULL;


UPDATE ref_nomenclatures.t_synonymes s SET cd_nomenclature = t.cd_nomenclature, mnemonique = t.mnemonique, label_default = t.label_default
FROM ref_nomenclatures.t_nomenclatures t
WHERE s.id_nomenclature = t.id_nomenclature;


