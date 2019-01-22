-- Suppression des communes hors du territoire concerné par GN2 parmis l'ensemble des communes de France Métro. intégrées lors de l'installation --> alléger la base
	-- Par exemple, on ne conserve ici que les communes des départements 38 et 26
	
DELETE FROM ref_geo.li_municipalities 
	WHERE insee_dep NOT IN ('26','38');
	
DELETE FROM ref_geo.l_areas 
	WHERE id_type = 25 AND left(area_code,2) NOT IN ('26','38');