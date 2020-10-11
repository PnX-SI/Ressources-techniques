-- BASE OO

-- table de correlation entre les couples (id_protocol, id_etude) et id_dataset

-- on ajoute les champs nom_etude et libelle_protocole pour plus de lisibilité
--   et pour facilité l'assignation à postériori des id_dataset

--DROP TABLE IF EXISTS export_oo.cor_dataset;

CREATE TABLE IF NOT EXISTS export_oo.cor_dataset AS
WITH count_protocole AS (
   SELECT
    COUNT(*) AS nb_by_protocole,
    s.id_protocole
    FROM saisie.saisie_observation s
    GROUP BY s.id_protocole
)
SELECT
    s.id_protocole,
    s.id_etude,
    e.nom_etude,
    p.libelle AS libelle_protocole,
    NULL::int AS id_dataset,
    COUNT(*) AS nb_row,
    cp.nb_by_protocole

    FROM saisie.saisie_observation s
    JOIN md.etude e
        ON e.id_etude = s.id_etude
    JOIN md.protocole p
        ON p.id_protocole = s.id_protocole
    JOIN count_protocole cp
        ON cp.id_protocole = s.id_protocole

    GROUP BY s.id_protocole, s.id_etude, e.nom_etude, p.libelle, id_dataset, cp.nb_by_protocole
    ORDER BY cp.nb_by_protocole DESC, nb_row DESC, nom_etude
;

SELECT * FROM export_oo.cor_dataset;