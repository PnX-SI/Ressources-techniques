-- BASE OO

-- table de correlation entre les couples (id_protocol, id_etude) et id_dataset

-- on ajoute les champs nom_etude et libelle_protocole pour plus de lisibilité
--   et pour facilité l'assignation à postériori des id_dataset


CREATE TABLE export_gn.cor_etude_protocole_dataset AS
SELECT DISTINCT
    s.id_protocole,
    s.id_etude,
    e.nom_etude,
    p.libelle AS libelle_protocole,
    NULL AS id_dataset

    FROM saisie.saisie_observation s
    JOIN md.etude e
        ON e.id_etude = s.id_etude
    JOIN md.protocole p
        ON p.id_protocole = s.id_protocole
;
