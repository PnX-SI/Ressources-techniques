-- Retrace les différents états de la table pr_occtax.t_releves_occtax en ne prenant en compte que la dernière des opérations par type

WITH d as (
    SELECT  DISTINCT ON (uuid_attached_row, operation_type) uuid_attached_row, operation_type, operation_date, table_content
    FROM gn_commons.t_history_actions
    WHERE id_table_location = 6
    ORDER BY uuid_attached_row, operation_type, operation_date DESC
 )
SELECT  operation_type, operation_date,  row_content.*
FROM d
JOIN LATERAL (
  SELECT *
  FROM json_to_record(
    d.table_content
  ) as x (
   id_releve_occtax int,
  unique_id_sinp_grp uuid,
  id_dataset integer,
  id_digitiser integer,
  observers_txt character varying(500),
  id_nomenclature_obs_technique integer,
  id_nomenclature_grp_typ integer,
  date_min timestamp without time zone,
  date_max timestamp without time zone,
  hour_min time without time zone,
  hour_max time without time zone,
  altitude_min integer,
  altitude_max integer,
  meta_device_entry character varying(20),
  comment text,
  geom_local geometry(Geometry,2154),
  geom_4326 geometry(Geometry,4326),
  "precision" integer
  )
) row_content ON true
ORDER BY id_releve_occtax, operation_date 
