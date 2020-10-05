-- table synonymes

DROP TABLE IF EXISTS export_oo.t_synonymes;

CREATE TABLE IF NOT EXISTS export_oo.t_synonymes (
    id_synonyme SERIAL NOT NULL,
    code_type character varying(255),
    cd_nomenclature character varying(255),
    mnemonique character varying(255),
    label_default character varying(255),
    obsocc_value character varying(255),
    test_value character varying(255),
    CONSTRAINT pk_t_synonymes_id_synonyme PRIMARY KEY (id_synonyme),
    CONSTRAINT unique_t_synonymes_code_type_cd_nomenclature_obsocc_value UNIQUE (code_type, cd_nomenclature, obsocc_value)
);

COPY export_oo.t_synonymes (code_type, cd_nomenclature, mnemonique, label_default, obsocc_value) FROM '/tmp/csv/nomenclature.csv' CSV;


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
 RETURNS TABLE(obsocc_value text, cd_nomenclature text, label_default text)  
--RETURNS SETOF RECORD
LANGUAGE plpgsql 
AS
$$
BEGIN
   RETURN QUERY EXECUTE format('
   SELECT DISTINCT  
%I::text, 
a.cd_nomenclature::text, 
s.label_default::text
FROM ( SELECT DISTINCT 
	%I,
	export_oo.get_synonyme_cd_nomenclature($2, %I::text) as cd_nomenclature
	FROM saisie.saisie_observation o
)a
 LEFT JOIN export_oo.t_synonymes s 
	ON s.cd_nomenclature = a.cd_nomenclature
		AND s.code_type = $2
;', colname_in, colname_in, colname_in)
USING colname_in, code_type_in;
--RETURN ;
END
$$
;

SELECT * FROM export_oo.check_synonyme_cd_nomenclature('ETA_BIO', 'determination');
SELECT * FROM export_oo.check_synonyme_cd_nomenclature('METH_OBS', 'determination');
SELECT * FROM export_oo.check_synonyme_cd_nomenclature('STADE_VIE', 'type_effectif');
SELECT * FROM export_oo.check_synonyme_cd_nomenclature('STATUT_VALID', 'statut_validation');
SELECT * FROM export_oo.check_synonyme_cd_nomenclature('SEXE', 'phenologie');



--SELECT DISTINCT
  
--type_effectif::text, a.cd_nomenclature::text, s.label_default::text
--FROM ( SELECT DISTINCT 
--	type_effectif,
--	export_oo.get_synonyme_cd_nomenclature('STADE_VIE', type_effectif) as cd_nomenclature
--	FROM saisie.saisie_observation o
--)a
--JOIN export_oo.t_synonymes s 
--	ON s.cd_nomenclature = a.cd_nomenclature
--		AND s.code_type = 'STADE_VIE'
--;

--SELECT DISTINCT 
--	determination,
--	export_oo.get_synonyme_cd_nomenclature('METH_OBS', determination::text) 
--	FROM saisie.saisie_observation o
--;

