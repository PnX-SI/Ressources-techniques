SELECT 1 AS ind, 'User', COUNT(*)
    FROM md.personne

UNION SELECT 2, 'Organisme' COUNT(*)
    FROM md.structure

UNION SELECT 3, 'Protocole', COUNT(*)
    FROM md.protocole

UNION SELECT 4, 'Protocole', COUNT(*)
    FROM md.protocole