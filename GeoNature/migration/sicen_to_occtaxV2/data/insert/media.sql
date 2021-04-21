ALTER TABLE gn_commons.t_medias ADD IF NOT EXISTS url_photo TEXT;
--DELETE FROM gn_commons.t_medias;

WITH tax AS ( SELECT
	cd_nom,
	replace(lb_nom, ' ', '_') AS lb_nom_title
	FROM taxonomie.taxref
), personnes AS ( SELECT 
	id_obs,
	UNNEST(STRING_TO_ARRAY(observateur, '&'))::int AS id_personne
	FROM export_oo.v_saisie_observation_cd_nom_valid so
),
author AS  (SELECT

id_obs,
STRING_AGG(TRIM(CONCAT(r.nom_role, ' ', r.prenom_role)) , ', ') AS author
FROM personnes p
JOIN utilisateurs.t_roles r
	ON (r.champs_addi->>'id_personne')::int = p.id_personne
GROUP BY id_obs
), url_photo AS (
	SELECT id_obs, TRANSLATE(url_photo,  'çéèîâ -(),''', 'ceeia______') AS url_photo
	FROM export_oo.v_saisie_observation_cd_nom_valid
)

INSERT INTO gn_commons.t_medias (
title_fr,
title_en,
meta_create_date,
media_path,
description_fr,
uuid_attached_row,
id_table_location,
author,
id_nomenclature_media_type,
url_photo
)
SELECT 
	CONCAT(so.cd_nom, '_', t.lb_nom_title, '_',  date_min::date::text) AS title_fr,
	'import from occtax' AS title_en, -- PATCH
	date_min AS meta_create_date,
	SPLIT_PART(u.url_photo, '/' , 3) AS media_path,
	TRIM(CONCAT(commentaire_photo, ' ', remarque_obs)) AS description_fr,
	unique_id_sinp_occtax AS uuid_attached_row,
	l.id_table_location,
	SUBSTRING(a.author, 0, 100),
	ref_nomenclatures.get_id_nomenclature('TYPE_MEDIA', '2'),
	u.url_photo
	
FROM export_oo.v_saisie_observation_cd_nom_valid so
JOIN tax t
	ON t.cd_nom = so.cd_nom
JOIN gn_commons.bib_tables_location l
	ON l.schema_name = 'pr_occtax'
		AND l.table_name = 'cor_counting_occtax'
JOIN author a 
	ON a.id_obs = so.id_obs
JOIN url_photo u 
	ON u.id_obs = so.id_obs
WHERE u.url_photo IS NOT NULL
;

UPDATE gn_commons.t_medias m 
	SET (title_en, media_path) = (
		' ',
		CONCAT('static/medias/', m2.id_table_location, '/', m2.id_media, '_', m2.media_path)  
) 
	FROM gn_commons.t_medias m2
		WHERE m.id_media = m2.id_media
		AND m2.title_en = 'import from occtax';

