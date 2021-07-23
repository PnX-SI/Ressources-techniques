CREATE EXTENSION IF NOT EXISTS postgres_fdw;

DROP SERVER IF EXISTS data_cheveche_server CASCADE;
CREATE SERVER data_cheveche_server  
      FOREIGN DATA WRAPPER postgres_fdw 
      OPTIONS (host 'ip-serveur', dbname 'faune', port '5432');

CREATE USER MAPPING
    FOR myuser
SERVER data_cheveche_server
OPTIONS (user 'myuser', password 'toto');

DROP SCHEMA IF EXISTS import_cheveches CASCADE;
CREATE SCHEMA IF NOT EXISTS import_cheveches;
IMPORT FOREIGN SCHEMA cheveches
   FROM SERVER data_cheveche_server INTO import_cheveches;

DROP SCHEMA IF EXISTS import_vocabulaire_controle;
CREATE SCHEMA IF NOT EXISTS import_vocabulaire_controle;
IMPORT FOREIGN SCHEMA vocabulaire_controle
    FROM SERVER data_cheveche_server INTO import_vocabulaire_controle;


-- cor_nomenclature_resultat

CREATE TABLE import_cheveches.cor_nomenclature_resultat AS
	SELECT t.id, n.id_nomenclature, code, label_fr
		FROM import_vocabulaire_controle.t_thesaurus t
		JOIN ref_nomenclatures.t_nomenclatures n
			ON t.code ='reponse_positive' AND n.cd_nomenclature = 'Pr' 
			OR t.code ='reponse_incertaine' AND n.cd_nomenclature = 'NSP' 
			OR t.code ='reponse_negative' AND n.cd_nomenclature = 'No' 	
		WHERE n.id_type = ref_nomenclatures.get_id_nomenclature_type('STATUT_OBS');

