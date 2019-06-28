
-- t_synonymes : table de correspondance entre les nomenclatures
-- Permet de passer du vocabulaire d'une source de données à la nomenclature geonature

DO $$
BEGIN
  CREATE TABLE ref_nomenclatures.t_synonymes
  (
    id_type integer,
    cd_nomenclature character varying(255),
    mnemonique character varying(255),
    label_default character varying(255),
    initial_value character varying(255),
    id_nomenclature int
  );
EXCEPTION WHEN others THEN
	RAISE NOTICE 'Table ref_nomenclatures.t_synonymes already exists';
END$$;



CREATE OR REPLACE FUNCTION ref_nomenclatures.get_synonymes_nomenclature(
    mytype character varying,
    myvalue character varying
)
  RETURNS int AS
$BODY$
DECLARE thecodenomenclature  int;
  BEGIN
    SELECT INTO thecodenomenclature id_nomenclature
    FROM ref_nomenclatures.t_synonymes n
    WHERE n.id_type = ref_nomenclatures.get_id_nomenclature_type(mytype) AND  unaccent(myvalue) ilike unaccent(n.initial_value);

    IF (thecodenomenclature IS NOT NULL) THEN
      RETURN thecodenomenclature;
    END IF;
    RETURN NULL;
return thecodenomenclature;
  END;
$BODY$
  LANGUAGE plpgsql IMMUTABLE
  COST 100;
