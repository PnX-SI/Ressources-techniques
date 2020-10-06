	
-- table synonymes

DROP TABLE IF EXISTS export_oo.t_synonymes;
CREATE TABLE IF NOT EXISTS export_oo.t_synonymes (
    id_synonyme SERIAL NOT NULL,
    code_type character varying(255),
    cd_nomenclature character varying(255),
    label_default character varying(255),
    obsocc_value character varying(255),
    test_value character varying(255),
    CONSTRAINT pk_t_synonymes_id_synonyme PRIMARY KEY (id_synonyme),
    CONSTRAINT unique_t_synonymes_code_type_cd_nomenclature_obsocc_value UNIQUE (code_type, cd_nomenclature, obsocc_value)
);

COPY export_oo.t_synonymes (code_type, cd_nomenclature, label_default, obsocc_value) FROM '/tmp/csv/synonyme.csv' CSV;


-- Fonction pour s'affranchir des MAJ min accents etc...

DROP FUNCTION IF EXISTS export_oo.format_value;
CREATE OR REPLACE FUNCTION export_oo.format_value(value_in character varying) RETURNS character varying
IMMUTABLE
LANGUAGE plpgsql AS
$$
DECLARE value_out character varying;
  BEGIN
SELECT INTO value_out
	TRIM(
		TRANSLATE(
			LOWER(value_in),
			'àâéèêîïôöùü',
			'aaeeeiioouu'
		)	
	)
;
return value_out;
  END;
$$;

UPDATE export_oo.t_synonymes SET test_value=export_oo.format_value(obsocc_value);

CREATE INDEX export_oo_t_synonymes_test_value_idx ON export_oo.t_synonymes(test_value);

-- Fonction (CODE_TYPE, VALUE_OBSOCC) => CD_NOMENCLATURE

DROP FUNCTION IF EXISTS export_oo.get_synonyme_cd_nomenclature;
CREATE OR REPLACE FUNCTION export_oo.get_synonyme_cd_nomenclature(code_type_in text, obsocc_value_in text) RETURNS text
IMMUTABLE
LANGUAGE plpgsql AS
$$
DECLARE cd_nomenclature_out text;
  BEGIN
  
  SELECT INTO cd_nomenclature_out cd_nomenclature 
	FROM export_oo.t_synonymes
	WHERE test_value = export_oo.format_value(obsocc_value_in)
		AND code_type = code_type_in
;
return cd_nomenclature_out;
  END;
$$;


DROP FUNCTION IF EXISTS export_oo.check_synonyme_cd_nomenclature;
CREATE OR REPLACE FUNCTION export_oo.check_synonyme_cd_nomenclature(code_type_in text, colname_in text)
 RETURNS TABLE(
	code_type text,
	obsocc_field_name text,
	obsocc_value text,
	cd_nomenclature text,
	label_default text
)  
--RETURNS SETOF RECORD
LANGUAGE plpgsql 
AS
$$
BEGIN
   RETURN QUERY EXECUTE format('
WITH obsocc_values AS (
	SELECT DISTINCT 
		%I::text AS obsocc_value
	FROM saisie.saisie_observation
), obsocc_synonymes AS (
	SELECT DISTINCT
		obsocc_value,
		export_oo.get_synonyme_cd_nomenclature($1, obsocc_value)::text AS cd_nomenclature,
		export_oo.format_value(obsocc_value) AS test_value
	FROM obsocc_values
)

SELECT DISTINCT

	$1 AS code_type,
	$2 AS obsocc_field_name,
	os.obsocc_value,
	os.cd_nomenclature,
	s.label_default::text
--	, s.test_value
FROM obsocc_synonymes os
LEFT JOIN export_oo.t_synonymes s 
	ON s.cd_nomenclature = os.cd_nomenclature
		AND s.obsocc_value = os.obsocc_value
		AND s.code_type = $1
ORDER BY cd_nomenclature, obsocc_value
;
;', colname_in)
USING code_type_in, colname_in;
END
$$
;

	
-- SELECT * FROM export_oo.check_synonyme_cd_nomenclature('ETA_BIO', 'determination');
-- SELECT * FROM export_oo.check_synonyme_cd_nomenclature('ETA_BIO', 'phenologie');

-- SELECT * FROM export_oo.check_synonyme_cd_nomenclature('METH_OBS', 'determination');
-- SELECT * FROM export_oo.check_synonyme_cd_nomenclature('STADE_VIE', 'type_effectif');
-- SELECT * FROM export_oo.check_synonyme_cd_nomenclature('STADE_VIE', 'phenologie');

-- SELECT * FROM export_oo.check_synonyme_cd_nomenclature('STATUT_VALID', 'statut_validation');
-- SELECT * FROM export_oo.check_synonyme_cd_nomenclature('SEXE', 'phenologie');



