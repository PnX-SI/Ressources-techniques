
-- Vue qui liste les relevés s'apparentent à des JDD (auxquels sont associées des observations)

CREATE OR REPLACE VIEW _import_serena.v_rnf_revl_jdd AS

SELECT DISTINCT relv_id, relv_nom, relv_categ_choi_id, c.choi_nom as relv_categ_choi_nom, relv_prop_id, s.srce_compnom_c, relv_1date_c, relv_2date_c, relv_comment, count(o.obse_relv_id) as total_obse
	FROM _import_serena.rnf_relv r
	LEFT JOIN _import_serena.rnf_choi c ON r.relv_categ_choi_id = c.choi_id
	LEFT JOIN _import_serena.rnf_srce s ON r.relv_prop_id = s.srce_id
	LEFT JOIN _import_serena.rnf_obse o ON r.relv_id = o.obse_relv_id
	GROUP BY relv_id, relv_nom, relv_categ_choi_id, c.choi_nom, relv_prop_id, s.srce_compnom_c, relv_prop_libel, relv_1date_c, relv_2date_c, relv_comment
	ORDER BY total_obse DESC, relv_id, relv_nom, relv_categ_choi_id, c.choi_nom, relv_prop_id, s.srce_compnom_c, relv_1date_c, relv_2date_c, relv_comment
	;