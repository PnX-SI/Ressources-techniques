-- synonyme
DROP TABLE IF EXISTS v1_compat.t_synonymes_v1;
CREATE TABLE v1_compat.t_synonymes_v1(
    code_type CHARACTER VARYING,
    cd_nomenclature CHARACTER VARYING,
    id_nomenclature INTEGER,
    gnv1_pk_values CHARACTER VARYING
);

COPY v1_compat.t_synonymes_v1 (code_type, cd_nomenclature, gnv1_pk_values) FROM '/tmp/synonyme_v1.csv' CSV DELIMITER ';';

UPDATE v1_compat.t_synonymes_v1 ns SET id_nomenclature=n.id_nomenclature FROM (
	SELECT n.cd_nomenclature, n.id_nomenclature, t.mnemonique
		FROM ref_nomenclatures.t_nomenclatures n
		JOIN ref_nomenclatures.bib_nomenclatures_types t
			ON t.id_type = n.id_type
)n 
WHERE ns.code_type = n.mnemonique 
	AND ns.cd_nomenclature = n.cd_nomenclature;

DROP FUNCTION IF EXISTS v1_compat.get_synonyme_id_nomenclature;
CREATE OR REPLACE FUNCTION v1_compat.get_synonyme_id_nomenclature(code_type_in text, gnv1_pk_value integer) RETURNS INTEGER
IMMUTABLE
LANGUAGE plpgsql AS
$$
DECLARE id_nomenclature_out text;
  BEGIN
  
  SELECT INTO id_nomenclature_out id_nomenclature 
	FROM v1_compat.t_synonymes_v1
    	WHERE gnv1_pk_value::text = ANY(STRING_TO_ARRAY(gnv1_pk_values, ','))
		AND code_type = code_type_in
;
return id_nomenclature_out;
  END;
$$;


-- select id_lot, v1_compat.get_synonyme_id_nomenclature('TYP_GRP', id_lot)
-- from v1_compat.bib_lots;