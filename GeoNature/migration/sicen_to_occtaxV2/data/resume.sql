SELECT 1 AS ind, 'User', COUNT(*)
        FROM export_oo.v_roles
        
UNION SELECT 2 AS ind, 'Organismes', COUNT(*)
    FROM export_oo.v_organismes

UNION SELECT 3 AS ind, 'CA', COUNT(*)
    FROM export_oo.v_acquisition_frameworks

UNION SELECT 4 AS ind, 'JDD', COUNT(*)
    FROM export_oo.v_datasets

UNION SELECT 5 AS ind, 'ObsOcc observation', COUNT(*)
    FROM export_oo.saisie_observation
    
UNION SELECT 6 AS ind, 'ObsOcc observation (Valid Tax)', COUNT(*)
    FROM export_oo.v_saisie_observation_cd_nom_valid s

UNION SELECT 7 AS ind, 'Releves', COUNT(*) 
    FROM export_oo.v_releves_occtax r

UNION SELECT 8 AS ind, 'pr_occtax.cor_role_releves_occtax cor', COUNT(*) 
    FROM export_oo.v_role_releves_occtax c

UNION SELECT 9 AS ind, 'Occurences', COUNT(*) 
    FROM export_oo.v_occurrences_occtax o

UNION SELECT 10 AS ind, 'Denombrements', COUNT(*) 
    FROM export_oo.v_counting_occtax c 

UNION SELECT 12 AS ind, 'Synthese', COUNT(*)
    FROM export_oo.v_synthese s 


ORDER BY ind;