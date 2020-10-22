-- BASE OO

-- table de correlation entre les couples (id_protocol, id_etude) et id_dataset

-- on ajoute les champs nom_etude et libelle_protocole pour plus de lisibilité
--   et pour facilité l'assignation à postériori des id_dataset

--DROP TABLE IF EXISTS export_oo.cor_dataset;

CREATE TABLE IF NOT EXISTS export_oo.cor_dataset AS

WITH saisie_personne AS (
    SELECT
        id_obs, UNNEST(string_to_array(so.observateur, '&'))::int AS id_personne
    FROM
        saisie.saisie_observation so 
),

saisie_structure AS (
    SELECT DISTINCT
        id_obs, p.id_structure, s.nom_structure
    FROM
        saisie_personne sp
    JOIN md.personne p ON
        p.id_personne = sp.id_personne
    JOIN md."structure" s ON
        s.id_structure = p.id_structure 
),

count_protocole AS (
    SELECT
        COUNT(*) AS nb_protocole, id_protocole
    FROM
        saisie.saisie_observation
    GROUP BY
        id_protocole
),

count_etude AS (
    SELECT
        COUNT(*) AS nb_etude, id_etude
    FROM
        saisie.saisie_observation
    GROUP BY
        id_etude
),

count_protocole_etude AS (
    SELECT
        COUNT(*) AS nb_protocole_etude, id_protocole, id_etude
    FROM
        saisie.saisie_observation
    GROUP BY
        id_etude, id_protocole
),

count_protocole_etude_structure AS (
    SELECT
        COUNT(*) AS nb_protocole_etude_structure, id_protocole, id_etude, id_structure
    FROM
        saisie.saisie_observation so
    JOIN saisie_structure st ON
        st.id_obs = so.id_obs
    GROUP BY
        id_etude, id_protocole, id_structure
)

SELECT

    p.libelle AS libelle_protocole,
    e.nom_etude,
    st.nom_structure,
    so.id_protocole,
    so.id_etude,
    st.id_structure,
    cp.nb_protocole,
    ce.nb_etude,
    cpe.nb_protocole_etude,
    cpes.nb_protocole_etude_structure,
    NULL::int AS id_dataset

    FROM
        saisie.saisie_observation so
    JOIN export_oo.saisie_observation so2
        ON so2.id_obs = so.id_obs   
    JOIN saisie_structure st ON
        st.id_obs = so.id_obs
    JOIN md.protocole p ON
        p.id_protocole = so.id_protocole
    JOIN md.etude e ON
        e.id_etude = so.id_etude
    JOIN count_protocole cp ON
        cp.id_protocole = so.id_protocole
    JOIN count_etude ce ON
        ce.id_etude = so.id_etude
    JOIN count_protocole_etude cpe ON
        cpe.id_protocole = so.id_protocole
        AND cpe.id_etude = so.id_etude
    JOIN count_protocole_etude_structure cpes ON
        cpes.id_protocole = so.id_protocole
        AND cpes.id_etude = so.id_etude
        AND cpes.id_structure = st.id_structure

    GROUP BY 
        libelle_protocole,
        e.nom_etude,
        st.nom_structure,
        so.id_protocole,
        so.id_etude ,
        st.id_structure,
        cp.nb_protocole,
        ce.nb_etude,
        cpe.nb_protocole_etude,
        cpes.nb_protocole_etude_structure
    
    ORDER BY
        nb_protocole DESC,
        nb_protocole_etude DESC,
        nb_protocole_etude_structure DESC
;    
   
SELECT * FROM export_oo.cor_dataset;