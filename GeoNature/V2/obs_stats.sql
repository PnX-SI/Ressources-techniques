------------------------------------------
-- STATISTIQUES DIVERSES - GeoNature V2 --
------------------------------------------

-- Observations d'un organisme (2 dans l'exemple) pour une année donnée
SELECT 
id_synthese, s.date_min, s.observers, 
ARRAY_AGG (c.id_organism || '-' || c.id_nomenclature_actor_role) Acteurs,
s.id_dataset, d.dataset_name 
FROM gn_synthese.synthese s
JOIN gn_meta.t_datasets d ON s.id_dataset = d.id_dataset
JOIN gn_meta.cor_dataset_actor c ON c.id_dataset = d.id_dataset
WHERE (EXTRACT (YEAR FROM s.date_min)) = 2015 AND c.id_organism = 2
GROUP BY id_synthese, s.id_dataset, s.date_min, s.observers, d.dataset_name
--LIMIT 100;

-- Nombre d'observations d'un organisme sur une année
SELECT 
count(distinct id_synthese)
FROM gn_synthese.synthese s
JOIN gn_meta.t_datasets d ON s.id_dataset = d.id_dataset
JOIN gn_meta.cor_dataset_actor c ON c.id_dataset = d.id_dataset
WHERE (EXTRACT (YEAR FROM s.date_min)) = 2022
AND c.id_organism = 2

-- Même requête écrite autrement
SELECT 
count(id_synthese)
FROM gn_synthese.synthese s
where id_dataset in 
  (select id_dataset  
  from gn_meta.t_datasets td 
  JOIN gn_meta.cor_dataset_actor c using (id_dataset)
  where c.id_organism = 2)
and (EXTRACT (YEAR FROM s.date_min)) = 2022;
                
-- Liste des JDD où le PNE (id_organisle = 2) est acteur : 
SELECT DISTINCT dataset_name FROM gn_meta.t_datasets d
   JOIN gn_meta.cor_dataset_actor cda on cda.id_dataset  = d.id_dataset 
   JOIN ref_nomenclatures.t_nomenclatures actorrole ON actorrole.id_nomenclature = cda.id_nomenclature_actor_role
WHERE cda.id_organism = 2
   AND actorrole.cd_nomenclature in ('1','2','3','4','5','6','7','8')
ORDER BY dataset_name

-- Liste des JDD et de leurs différents acteurs
SELECT d.id_dataset, d.dataset_name, cda.id_organism, o.nom_organisme as acteur_organisme, cda.id_role, r.nom_role || ' ' || r.prenom_role as acteur_role, cda.id_nomenclature_actor_role, n.mnemonique, count(s.*) as nb_obs
FROM gn_synthese.synthese s 
RIGHT JOIN gn_meta.t_datasets d ON d.id_dataset = s.id_dataset
LEFT JOIN gn_meta.cor_dataset_actor cda ON cda.id_dataset  = d.id_dataset 
LEFT JOIN ref_nomenclatures.t_nomenclatures n ON n.id_nomenclature = cda.id_nomenclature_actor_role 
LEFT JOIN utilisateurs.t_roles r ON r.id_role = cda.id_role 
LEFT JOIN utilisateurs.bib_organismes o ON o.id_organisme = cda.id_organism 
--WHERE cda.id_organism = 2
--AND n.cd_nomenclature in('1','2','3','4','5','6','7','8')
GROUP BY d.id_dataset, d.dataset_name, cda.id_organism, o.nom_organisme, cda.id_role, r.nom_role || ' ' || r.prenom_role, cda.id_nomenclature_actor_role, n.mnemonique
ORDER BY d.id_dataset;

-- Observations et acteurs de leurs JDD - Par Amandine Sahl
 WITH ds_actors AS (
         SELECT cda.id_dataset,
            t_1.mnemonique,
            array_agg(o.nom_organisme) AS actors
           FROM gn_meta.cor_dataset_actor cda
             JOIN ref_nomenclatures.t_nomenclatures t_1 ON cda.id_nomenclature_actor_role = t_1.id_nomenclature
             JOIN utilisateurs.bib_organismes o ON cda.id_organism = o.id_organisme
          GROUP BY cda.id_dataset, t_1.mnemonique
        ), dsa_json AS (
         SELECT ds_actors.id_dataset,
            json_object_agg(ds_actors.mnemonique, ds_actors.actors) AS jdd_actors
           FROM ds_actors
          GROUP BY ds_actors.id_dataset
        )
 SELECT s.id_synthese AS "idSynthese",
    dsa_json.jdd_actors
   FROM gn_synthese.synthese s
     JOIN gn_meta.t_datasets d ON d.id_dataset = s.id_dataset
     JOIN dsa_json ON dsa_json.id_dataset = d.id_dataset
 LIMIT 1000;

-- Nombre de taxons observés en 2001
WITH nby AS
(
 SELECT DISTINCT taxonomie.find_cdref(s.cd_nom) 
 FROM gn_synthese.synthese s 
 WHERE EXTRACT('year' FROM date_min) = 2001
) 
SELECT count(*) FROM nby;
-- Similaire à 
SELECT count (DISTINCT taxonomie.find_cdref(s.cd_nom))
FROM gn_synthese.synthese s 
WHERE EXTRACT('year' FROM date_min) = 2001;

-- Nombre de taxons observés avant 2018
WITH nby AS
(
 SELECT DISTINCT taxonomie.find_cdref(s.cd_nom) 
 FROM gn_synthese.synthese s 
 WHERE EXTRACT('year' FROM date_min) < 2018
) 
SELECT count(*) FROM nby;

-- Lister les observations de la synthèse dont le niveau de diffusion est différent de "Aucune" 
-- et où le statut de diffusion est égale à "Présent"
SELECT s.id_synthese,
  s.cd_nom,
  s.date_min AS dateobs,
  s.observers AS observateurs,
  (s.altitude_min + s.altitude_max) / 2 AS altitude_retenue,
  s.count_min AS effectif_total,
  dl.cd_nomenclature::integer AS diffusion_level
FROM gn_synthese.synthese s
  LEFT JOIN ref_nomenclatures.t_nomenclatures dl ON s.id_nomenclature_diffusion_level = dl.id_nomenclature
  LEFT JOIN ref_nomenclatures.t_nomenclatures st ON s.id_nomenclature_observation_status = st.id_nomenclature
WHERE (NOT dl.cd_nomenclature::text = '4'::text OR s.id_nomenclature_diffusion_level IS NULL) 
  AND st.cd_nomenclature::text = 'Pr'::text

-- Nb d'observations par regne
SELECT count(*) nb_data, t.regne
FROM gn_synthese.synthese s
JOIN taxonomie.taxref t ON t.cd_nom = s.cd_nom
GROUP BY t.regne;

-- Nb de taxons par regne
-- Groupé par cd_ref pour ne pas compter les synonymes
SELECT count(*), a.regne FROM(
SELECT count(*) nb_data, t.regne, t.cd_ref
FROM gn_synthese.synthese s
JOIN taxonomie.taxref t ON t.cd_nom = s.cd_nom
GROUP BY t.regne, t.cd_ref) a
GROUP BY a.regne;

-- Liste des observations d'un agent entre 2017 et 2020
-- Pour être plus précis, on pourrait utiliser son id_role dans la table gn_synthese.cor_observer_synthese
SELECT s.id_synthese, s.cd_nom, t.nom_complet, t.nom_vern, s.date_min, s.observers FROM gn_synthese.synthese s
JOIN taxonomie.taxref t ON t.cd_nom = s.cd_nom
WHERE EXTRACT('year' FROM date_min) >= 2017
AND EXTRACT('year' FROM date_max) <= 2020
AND observers ILIKE '%corail%'
ORDER BY date_min;

-- Liste des taxons observés par un agent entre 2017 et 2020
SELECT DISTINCT t.cd_ref, t.nom_complet, t.nom_vern, count(s.id_synthese) AS NbObs FROM gn_synthese.synthese s 
JOIN taxonomie.taxref t ON t.cd_nom = s.cd_nom
WHERE EXTRACT('year' FROM s.date_min) >= 2017
AND EXTRACT('year' FROM s.date_max) <= 2020
AND s.observers ILIKE '%corail%'
GROUP BY t.cd_ref, t.nom_complet, t.nom_vern
ORDER BY NbObs DESC;

-- Taxons observés par un agent qui n'étaient pas connus avant 2017
-- Ils peuvent avoir été découverts par un autre agent avant lui entre 2017 et 2020
-- Pour être plus précis, on pourrait utiliser son id_role dans la table gn_synthese.cor_observer_synthese
WITH TaxonsConnusAvant2017 AS
(
 -- Lister les taxons connus avant 2017
 SELECT DISTINCT taxonomie.find_cdref(s.cd_nom) 
 FROM gn_synthese.synthese s 
 WHERE EXTRACT('year' FROM date_min) < 2017
)
SELECT DISTINCT t.cd_ref, t.nom_complet, t.nom_vern, count(s.id_synthese) AS NbObs FROM gn_synthese.synthese s 
  JOIN taxonomie.taxref t ON t.cd_nom = s.cd_nom
WHERE EXTRACT('year' FROM s.date_min) >= 2017
  AND EXTRACT('year' FROM s.date_max) <= 2020
  AND s.observers ILIKE '%corail%'
  -- Ne garder que les taxons qui ne sont pas dans la liste des taxons connus avant 2017
  AND t.cd_ref NOT IN (Select * FROM TaxonsConnusAvant2017)
GROUP BY t.cd_ref, t.nom_complet, t.nom_vern
ORDER BY NbObs DESC;

-- Nombre de nouvelles espèces pour une année
SELECT COUNT(*) FROM (
    SELECT DISTINCT t.cd_ref 
    FROM gn_synthese.synthese s JOIN taxonomie.taxref t ON t.cd_nom=s.cd_nom 
    WHERE date_part('year', date_min) = :year
    EXCEPT
    SELECT DISTINCT t.cd_ref 
    FROM gn_synthese.synthese s JOIN taxonomie.taxref t ON t.cd_nom=s.cd_nom 
    WHERE date_part('year', date_min) < :year 
) sub

-- Nb de taxons connus à l'année X / Taxons recontactés / Taxons non recontactés / Nouveaux taxons
WITH 
total_before_current_year as (
	SELECT DISTINCT cd_ref FROM gn_synthese.synthese s JOIN taxonomie.taxref t ON t.cd_nom=s.cd_nom WHERE date_part('year', date_min) < :selectedYear
),
recontactees AS
(SELECT DISTINCT cd_ref FROM gn_synthese.synthese s JOIN taxonomie.taxref t ON t.cd_nom=s.cd_nom WHERE date_part('year', date_min) < :selectedYear
INTERSECT
SELECT DISTINCT cd_ref FROM gn_synthese.synthese s JOIN taxonomie.taxref t ON t.cd_nom=s.cd_nom WHERE date_part('year', date_min) = :selectedYear),
non_recontactees AS
(SELECT DISTINCT cd_ref FROM gn_synthese.synthese s JOIN taxonomie.taxref t ON t.cd_nom=s.cd_nom WHERE date_part('year', date_min) < :selectedYear
EXCEPT
SELECT DISTINCT cd_ref FROM gn_synthese.synthese s JOIN taxonomie.taxref t ON t.cd_nom=s.cd_nom WHERE date_part('year', date_min) = :selectedYear),
nouvelles AS
(SELECT DISTINCT cd_ref FROM gn_synthese.synthese s JOIN taxonomie.taxref t ON t.cd_nom=s.cd_nom WHERE date_part('year', date_min) = :selectedYear
EXCEPT
SELECT DISTINCT cd_ref FROM gn_synthese.synthese s JOIN taxonomie.taxref t ON t.cd_nom=s.cd_nom WHERE date_part('year', date_min) < :selectedYear)
select count(*) as total_before from total_before_current_year
union ALL
SELECT count(cd_ref) FROM recontactees
UNION ALL
SELECT count(cd_ref) FROM non_recontactees
UNION ALL
SELECT count(cd_ref) FROM nouvelles

-- Tous les taxons de flore observés dans le PNE
Select count(distinct t.cd_ref)
from gn_synthese.synthese s
join taxonomie.taxref t on t.cd_nom = s.cd_nom
join gn_synthese.cor_area_synthese cas using(id_synthese)
where t.regne = 'Plantae' and cas.id_area = 1000279
 
-- Tous les taxons de flore patrimoniaux observés dans le PNE
Select count(distinct t.cd_ref)
from gn_synthese.synthese s
join taxonomie.taxref t on t.cd_nom = s.cd_nom
join gn_synthese.cor_area_synthese cas using(id_synthese)
join taxonomie.cor_taxon_attribut cta on cta.cd_ref = t.cd_ref
where t.regne = 'Plantae' and cas.id_area = 1000279 and cta.id_attribut = 1 and cta.valeur_attribut = 'oui'
 
-- Tous les taxons de flore d'interet patrimoniaux observés dans le PNE
select count(distinct t.cd_ref)
from gn_synthese.synthese s
join taxonomie.taxref t on t.cd_nom = s.cd_nom
join gn_synthese.cor_area_synthese cas using(id_synthese)
where t.regne = 'Plantae' and cas.id_area = 1000279 

-- Les taxons de flore des JDD où le PNE est acteur
Select count(distinct t.cd_ref)
from gn_synthese.synthese s
join taxonomie.taxref t on t.cd_nom = s.cd_nom
join gn_synthese.cor_area_synthese cas using(id_synthese)
join gn_meta.t_datasets td on s.id_dataset = td.id_dataset
join gn_meta.cor_dataset_actor cda on cda.id_dataset = td.id_dataset
where t.regne = 'Plantae' and cas.id_area = 1000279 and cda.id_organism = 2;


-- Espece la plus observée par année (changer le rang pour avoir la 1ere, la 2eme etc...)
select * from (
with nb_by_year as ( 
	select count(*) as nb, t.lb_nom, t.regne, date_part('year', s.date_fin) as year_
	from gn_exports.v_synthese_sinp_pne  s 
	join taxonomie.taxref t on t.cd_nom = s.cd_nom
	group by t.cd_nom, date_part('year', s.date_fin)
	order by nb desc
)
select lb_nom, nb, year_, regne,
rank() over(partition by year_ order by nb desc) as rang
from nb_by_year 
) t where rang = 1
order by year_ desc
;
