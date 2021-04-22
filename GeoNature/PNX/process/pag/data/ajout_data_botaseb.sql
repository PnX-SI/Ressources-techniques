------------------- Injection BD photo seb
--1/ création des releves/occurrences/counting
--2/ ftp pour envoyer les photos dans les rep:
geonature/backend/static/medias/4/photoici.jpg
--3/ ajout des medias dans la table gn_commons.t_medias
avec 
	id_table_location = 4 (cf.  gn_commons.bib_tables_location)
	id_nomenclature_media_type = photo (458?)
	uuid_occurrence/uuid_denombrement
	adresse de la photos: 'static/medias/4/photoici.JPG'