SELECT 1 AS ind, 'Users', COUNT(*)
    FROM md.personne

UNION SELECT 2 AS ind, 'Organismes', COUNT(*)
    FROM md.structure

UNION SELECT 3 AS ind, 'Protocoles', COUNT(*)
    FROM md.protocole

UNION SELECT 4 AS ind, 'Etudes', COUNT(*)
    FROM md.etude

UNION SELECT 5 AS ind, 'Observations', COUNT(*)
    FROM saisie.saisie_observation
ORDER BY ind
