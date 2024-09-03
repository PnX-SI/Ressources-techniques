create or replace function postgis.coordinates_in_text_array_to_linestring (
	coordinates_text_array text /* [[x1, y1, z1], [x2, y2, z2], [x3, y3, z3], ...] */
)
RETURNS geometry(LineString, 2154) 
	
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
DECLARE	geom_txt text;
DECLARE	geom geometry(LineString, 2154);
BEGIN
  select 
	replace (
		replace(
			replace(coordinates_text_array, '],[', '), ST_MakePoint('), 
			'[[', 'ST_Transform(ST_SetSRID(ST_Force2D(ST_MakeLine(ARRAY[ST_MakePoint('
		),
		']]', ')])), 4326), 2154)'
	)
	INTO geom_txt;

	EXECUTE 'SELECT ' || geom_txt INTO geom;

	RETURN geom;
END;
$BODY$;
