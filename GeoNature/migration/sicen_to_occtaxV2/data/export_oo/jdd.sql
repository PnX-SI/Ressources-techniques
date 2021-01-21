-- BASE OO

-- table de correlation entre les couples (id_protocol, id_etude) et id_dataset

-- on ajoute les champs nom_etude et libelle_protocole pour plus de lisibilité
--   et pour facilité l'assignation à postériori des id_dataset

--DROP TABLE IF EXISTS export_oo.cor_dataset;

CREATE TABLE IF NOT EXISTS export_oo.cor_dataset AS

WITH structure as (
select distinct STRING_TO_ARRAY(observateur, '&'), id_obs, s.id_structure, s.nom_structure 
from saisie.saisie_observation so
join md.personne p on p.id_personne::text = any(STRING_TO_ARRAY(observateur, '&'))
join md.structure s on p.id_structure = s.id_structure
group by so.id_obs, s.id_structure, s.nom_structure
order by s.id_structure
),

structure_agg AS (
	select id_obs, STRING_AGG(id_structure::text, '&') as ids_structure, STRING_AGG(nom_structure, ' & ') as noms_structure
	from structure
	Group by id_obs
),

saisie_st AS (
    SELECT so.*, st.ids_structure, noms_structure
    FROM saisie.saisie_observation so
    JOIN structure_agg st ON st.id_obs = so.id_obs 

),

saisie_personne AS (
    SELECT
        id_obs, UNNEST(string_to_array(so.observateur, '&'))::int AS id_personne
    FROM
        saisie.saisie_observation so 
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
  set-title geonature code
  cd /home/joel/info/app_gn/GeoNature
  source backend/venv/bin/activate
  set-title geonature backend
  cd /home/joel/info/app_gn/GeoNature
  source backend/venv/bin/activate
  geonature dev_back
  set-title geonature frontend
  cd /home/joel/info/app_gn/GeoNature
  source backend/venv/bin/activate
  geonature dev_front
  set-title monitoring
  cd /home/joel/info/app_gn/gn_module_monitoring
  set-title protocols
  cd /home/joel/info/app_gn/protocoles_suivi
        saisie.saisie_observation
    GROUP BY
        id_etude
),

count_protocole_etude AS (
    SELECT
        COUNT(*) AS nb_protocole_etude, id_protocole, id_etude
    FROM
        saisie.saisie_observation so
    GROUP BY
        id_etude, id_protocole
),


count_protocole_etude_structure AS (
    SELECT
        COUNT(*) AS nb_protocole_etude_structure, id_protocole, id_etude, so.ids_structure
    FROM
        saisie_st so
    GROUP BY
        id_etude, id_protocole, so.ids_structure
)

SELECT

    p.libelle AS libelle_protocole,
    e.nom_etude,
    so.ids_structure,
    so.noms_structure,
    so.id_protocole,
    so.id_etude,
    cp.nb_protocole,
    ce.nb_etude,
    cpe.nb_protocole_etude,
    cpes.nb_protocole_etude_structure,
    NULL::int AS id_dataset

    FROM
        saisie_st so
    JOIN export_oo.saisie_observation so2
        ON so2.id_obs = so.id_obs
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
        AND cpes.ids_structure = so.ids_structure

    GROUP BY 
        libelle_protocole,
        e.nom_etude,
        so.noms_structure,
        so.ids_structure,
        so.id_protocole,
        so.id_etude ,
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