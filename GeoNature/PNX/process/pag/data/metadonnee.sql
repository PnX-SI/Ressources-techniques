-- meta données

-- Protocoles

INSERT INTO gn_meta.sinp_datatype_protocols (
  id_protocol,
  protocol_name,
  protocol_desc,
  id_nomenclature_protocol_type
)
SELECT 
  id_protocole,
  nom_protocole,
  'Question : ' || COALESCE(question,'none') || ' - ' || 
    'Objectifs : ' || COALESCE(objectifs,'none') || ' - ' || 
    'Méthode : ' || COALESCE(methode,'none') || ' - ' ||  
    'Avancement : ' || COALESCE(avancement,'none') || ' - ' ||  
    'Date_debut : ' || COALESCE(date_debut,'1000-01-01') || ' - ' ||  
    'Date_fin : ' || COALESCE(date_fin, '3000-01-01')
    AS protocol_desc,
  ref_nomenclatures.get_id_nomenclature('TYPE_PROTOCOLE','1') AS id_nomenclature_protocol_type
FROM v1_compat.t_protocoles p
WHERE nom_protocole IS NOT NULL
AND id_protocole <> 0;


-- CA

INSERT INTO gn_meta.t_acquisition_frameworks (
  id_acquisition_framework,
  acquisition_framework_name,
  acquisition_framework_desc,
  id_nomenclature_territorial_level,
  territory_desc,
  id_nomenclature_financing_type,
  is_parent,
  acquisition_framework_start_date
)
SELECT DISTINCT
  p.id_programme,
  nom_programme,
  desc_programme,
  ref_nomenclatures.get_id_nomenclature('NIVEAU_TERRITORIAL','4') AS id_nomenclature_territorial_level,
  'Territoire du parc Amazonien de Guyanne' AS territory_desc,
  ref_nomenclatures.get_id_nomenclature('TYPE_FINANCEMENT','1') AS id_nomenclature_financing_type,
  false AS is_parent,
  '1000-01-01'::date AS acquisition_framework_start_date
FROM v1_compat.bib_programmes p
JOIN v1_compat.bib_lots l ON l.id_programme = p.id_programme
;


-- JDD
INSERT INTO gn_meta.t_datasets (
  id_dataset,
  id_acquisition_framework,
  dataset_name,
  dataset_shortname,
  dataset_desc,
  id_nomenclature_data_type,
  marine_domain,
  terrestrial_domain,
  id_nomenclature_dataset_objectif,
  id_nomenclature_collecting_method,
  id_nomenclature_data_origin,
  id_nomenclature_source_status,
  id_nomenclature_resource_type
)
SELECT DISTINCT
  id_lot,
  id_programme,
  nom_lot,
  nom_lot,
  desc_lot,
  ref_nomenclatures.get_id_nomenclature('DATA_TYP','1') AS id_nomenclature_data_type, --nomenclature 103 = "donnée source"
  false AS marine_domain,
  true AS terrestrial_domain,
  ref_nomenclatures.get_id_nomenclature('JDD_OBJECTIFS','1.1') AS id_nomenclature_dataset_objectif, --nomenclature 114 à reprendre lot par lot
  ref_nomenclatures.get_id_nomenclature('METHO_RECUEIL','1') AS id_nomenclature_collecting_method, --nomenclature 115 = "Observation directe : Vue, écoute, olfactive, tactile"
  ref_nomenclatures.get_id_nomenclature('DS_PUBLIQUE','Pu') AS id_nomenclature_data_origin, --nomenclature 2 à reprendre lot par lot
  ref_nomenclatures.get_id_nomenclature('STATUT_SOURCE','Te') AS id_nomenclature_source_status, --nomenclature 19 à reprendre lot par lot
  ref_nomenclatures.get_id_nomenclature('RESOURCE_TYP','1') AS id_nomenclature_resource_type --nomenclature 102 = "jeu de données"
FROM v1_compat.bib_lots
;



-- COR ACTOR
-- on met tout à pag producteur à affiner si besoin

INSERT INTO gn_meta.cor_dataset_actor(id_dataset, id_organism, id_nomenclature_actor_role)
SELECT id_dataset, o.id_organisme, ref_nomenclatures.get_id_nomenclature('ROLE_ACTEUR', '6')
  FROM gn_meta.t_datasets t
  JOIN utilisateurs.bib_organismes o 
    ON o.nom_organisme = 'Parc amazonien de Guyane'
;

