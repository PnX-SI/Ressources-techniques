
-- Vue qui liste les protocoles associés à des observations 
--> Méthode d'observation ? s'apparentent à des JDD ?
--> Contrôle manuel nécesaire pour vérifier le rapprochement de vocabulaire

CREATE OR REPLACE VIEW _import_serena.v_rnf_protocole_jdd AS

SELECT DISTINCT req.obse_pcole_choi_id,
           		 rnf_choi.choi_nom AS protocole,
 				 req.total_obse
 	FROM ( SELECT DISTINCT o.obse_pcole_choi_id, count(o.obse_id) as total_obse
           	FROM _import_serena.rnf_obse o
			GROUP BY o.obse_pcole_choi_id) req
    JOIN _import_serena.rnf_choi ON req.obse_pcole_choi_id = rnf_choi.choi_id
 	ORDER BY total_obse desc, protocole;