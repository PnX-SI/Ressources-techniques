--### Cette requête crée une vue matérialisée qui reformate la structure de la table et les valeurs brutes de serenabase.rnf_obse (table principales qui contient les observations)

--> /!\ Cette vue ne gère que les géométrie de type POINT. Pour gérer des types polygones ou polylignes cette requête est a adapter (créer une vue mat. pour chaque type des geométrie par exemple)

-- On réalise les conversions de types, transformations et jointures nécessaires pour disposer d'une table de synthèse plus facilement exploitable et lisible.
-- De nombreusees sous-requêtes sont pré-exposées en utilisant les Common Table Expressions (CTE)

-- DROP MATERIALIZED VIEW _import_serena.vm_obs_serena_detail_point;

CREATE MATERIALIZED VIEW _import_serena.vm_obs_serena_detail_point AS 
 WITH 
  obs_obsv AS (
  SELECT q.obse_obsv_id,
	 rnf_srce.srce_compnom_c AS observateur
    FROM ( SELECT DISTINCT o.obse_obsv_id
		    FROM _import_serena.rnf_obse o) q
	  JOIN _import_serena.rnf_srce ON q.obse_obsv_id = rnf_srce.srce_id
  ), 
  obs_deter AS (
   SELECT q.obse_detm_id,
  	rnf_srce.srce_compnom_c AS determinateur
     FROM ( SELECT DISTINCT o.obse_detm_id
  		   FROM _import_serena.rnf_obse o) q
  	 JOIN _import_serena.rnf_srce ON q.obse_detm_id = rnf_srce.srce_id
  ),
  obs_taxon AS (
   SELECT q.taxo_id,
  	q.nom_verna,
  	q.nom_latin,	
  	t1.taxo_latin_c AS nom_valide
     FROM ( SELECT rnf_taxo_1.taxo_id,
  			rnf_taxo_1.taxo_vernacul AS nom_vern,
  			rnf_taxo_1.taxo_latin_c AS nom_latin,
  			rnf_taxo_1.taxo_synonym_id			
  		   FROM ( SELECT DISTINCT o.obse_taxo_id
  				   FROM _import_serena.rnf_obse o) q1
  			 JOIN _import_serena.rnf_taxo t1 ON q1.obse_taxo_id = t.taxo_id) q
  	 LEFT JOIN _import_serena.rnf_taxo t2 ON q.taxo_synonym_id = t.taxo_id
  ),        
  obs_prot AS (
   SELECT q.obse_pcole_choi_id,
      rnf_choi.choi_nom AS protocole
     FROM ( SELECT DISTINCT o.obse_pcole_choi_id
             FROM _import_serena.rnf_obse o) q
       JOIN _import_serena.rnf_choi ON q.obse_pcole_choi_id = rnf_choi.choi_id
  ), 
  obs_valid AS (
   SELECT q.obse_validat_choi_id,
      rnf_choi.choi_nom AS statut_validation
     FROM ( SELECT DISTINCT o.obse_validat_choi_id
             FROM _import_serena.rnf_obse o) q
       JOIN _import_serena.rnf_choi ON q.obse_validat_choi_id = rnf_choi.choi_id
  ), 
  obs_confid AS (
   SELECT q.obse_confid_choi_id,
      rnf_choi.choi_nom AS confidentialite
     FROM ( SELECT DISTINCT o.obse_confid_choi_id
             FROM _import_serena.rnf_obse o) q
       JOIN _import_serena.rnf_choi ON q.obse_confid_choi_id = rnf_choi.choi_id
  ), 
  obs_sexe AS (
   SELECT q.obse_sex_choi_id,
      rnf_choi.choi_nom AS sexe
     FROM ( SELECT DISTINCT o.obse_sex_choi_id
             FROM _import_serena.rnf_obse o) q
       JOIN _import_serena.rnf_choi ON q.obse_sex_choi_id = rnf_choi.choi_id
  ), 
  obs_stadevie AS (
   SELECT q.obse_stade_choi_id,
      rnf_choi.choi_nom AS stade_vie
     FROM ( SELECT DISTINCT o.obse_stade_choi_id
             FROM _import_serena.rnf_obse o) q
       JOIN _import_serena.rnf_choi ON q.obse_stade_choi_id = rnf_choi.choi_id
  ), 
  obs_age_unite AS (
   SELECT q.obse_ageunit_choi_id,
      rnf_choi.choi_nom AS unite
     FROM ( SELECT DISTINCT o.obse_ageunit_choi_id
             FROM _import_serena.rnf_obse o) q
       JOIN _import_serena.rnf_choi ON q.obse_ageunit_choi_id = rnf_choi.choi_id
  ), 
  obs_abond AS (
   SELECT q.obse_abond_choi_id,
      rnf_choi.choi_nom AS abondance
     FROM ( SELECT DISTINCT o.obse_abond_choi_id
             FROM _import_serena.rnf_obse o) q
       JOIN _import_serena.rnf_choi ON q.obse_abond_choi_id = rnf_choi.choi_id
  ), 
  obs_type_denombr AS (
   SELECT q.obse_precis_choi_id,
      rnf_choi.choi_nom AS type_denombrement
     FROM ( SELECT DISTINCT o.obse_precis_choi_id
             FROM _import_serena.rnf_obse o) q
       JOIN _import_serena.rnf_choi ON q.obse_precis_choi_id = rnf_choi.choi_id
  ), 
  obs_statubio AS (
    (SELECT q.obse_activ_choi_id,
      rnf_choi.choi_nom AS statut_bio
     FROM ( SELECT DISTINCT o.obse_activ_choi_id
             FROM _import_serena.rnf_obse o) q
       JOIN _import_serena.rnf_choi ON q.obse_activ_choi_id = rnf_choi.choi_id)
    UNION
    (SELECT q.obse_caract_choi_id,
      rnf_choi.choi_nom AS statut_bio
     FROM ( SELECT DISTINCT o.obse_caract_choi_id
             FROM _import_serena.rnf_obse o) q
       JOIN _import_serena.rnf_choi ON q.obse_caract_choi_id = rnf_choi.choi_id)
  ), 
  obs_repro AS (
   SELECT q.obse_caract_choi_id,
      rnf_choi.choi_nom AS repro
     FROM ( SELECT DISTINCT o.obse_caract_choi_id
             FROM _import_serena.rnf_obse o) q
       JOIN _import_serena.rnf_choi ON q.obse_caract_choi_id = rnf_choi.choi_id
  ), 
  obs_methode_loc AS (
   SELECT q.obse_methloc_choi_id,
      rnf_choi.choi_nom AS methode_loc
     FROM ( SELECT DISTINCT o.obse_methloc_choi_id
             FROM _import_serena.rnf_obse o) q
       JOIN _import_serena.rnf_choi ON q.obse_methloc_choi_id = rnf_choi.choi_id
  ), 
  obs_sociabilite AS (
   SELECT q.obse_soci_choi_id,
      rnf_choi.choi_nom AS sociabilite
     FROM ( SELECT DISTINCT o.obse_soci_choi_id
             FROM _import_serena.rnf_obse o) q
       JOIN _import_serena.rnf_choi ON q.obse_soci_choi_id = rnf_choi.choi_id
  ), 
  obs_comportement AS (
   SELECT q.obse_comp_choi_id,
      rnf_choi.choi_nom AS comportement
     FROM ( SELECT DISTINCT o.obse_comp_choi_id
             FROM _import_serena.rnf_obse o) q
       JOIN _import_serena.rnf_choi ON q.obse_comp_choi_id = rnf_choi.choi_id
  ), 
  obs_methode_obs AS (
   SELECT q.obse_contact_choi_id,
      rnf_choi.choi_nom AS methode_obs
     FROM ( SELECT DISTINCT o.obse_contact_choi_id
             FROM _import_serena.rnf_obse o) q
       JOIN _import_serena.rnf_choi ON q.obse_contact_choi_id = rnf_choi.choi_id
  ), 
  obs_etat_bio AS (
   SELECT q.obse_contact2_choi_id,
      rnf_choi.choi_nom AS etat_bio
     FROM ( SELECT DISTINCT o.obse_contact2_choi_id
             FROM _import_serena.rnf_obse o) q
       JOIN _import_serena.rnf_choi ON q.obse_contact2_choi_id = rnf_choi.choi_id
  ), 
  obs_etat_sante AS (
   SELECT q.obse_etat_choi_id,
      rnf_choi.choi_nom AS etat_sante
     FROM ( SELECT DISTINCT o.obse_etat_choi_id
             FROM _import_serena.rnf_obse o) q
       JOIN _import_serena.rnf_choi ON q.obse_etat_choi_id = rnf_choi.choi_id
  ), 
  obs_geom AS (
         SELECT o.obse_id,
            'obse'::text AS source_geom,
            o.geom_obse AS geom_pt
           FROM _import_serena.rnf_obse o
          WHERE o.geom_obse IS NOT NULL 
			AND geometrytype(o.geom_obse) ILIKE 'Point'::text
			AND o.geom_site IS NULL
        UNION
         SELECT o.obse_id,
            'site'::text AS source_geom,
            o.geom_site AS geom_pt
           FROM _import_serena.rnf_obse o
          WHERE o.geom_site IS NOT NULL 
			AND geometrytype(o.geom_site) ILIKE 'Point'::text
			AND o.geom_obse IS NULL
  )

 SELECT 
 	rnf_obse.obse_id,
	rnf_obse.obse_relv_id,
    CASE
        WHEN (substr(rnf_obse.obse_date::text, 5, 4) ~ '^([0-9]+[.]?[0-9]*|[.][0-9]+)$'::text) = true THEN to_date("left"(rnf_obse.obse_date::text, 8), 'YYYYMMDD'::text)
        ELSE to_date(concat("left"(rnf_obse.obse_date::text, 4), '0601'), 'YYYYMMDD'::text)
    END AS date,
    obs_obsv.observateur,
    obs_deter.determinateur,
    rnf_obse.obse_crea_user_id AS numerisateur,
    obs_taxon.nom_verna,
    obs_taxon.nom_latin,
    obs_taxon.nom_valide,
    rnf_taxo.taxo_mnhn_id,
    obs_prot.protocole,
    obs_valid.statut_validation,
    obs_confid.confidentialite,
    obs_type_denombr.type_denombrement,
    obs_sexe.sexe,
    obs_stadevie.stade_vie,
    obs_statubio.statut_bio,
    (rnf_obse.obse_age::text || ' '::text) || obs_age_unite.unite::text AS age,
    obs_abond.abondance,
    rnf_obse.obse_nombre::integer AS effectif,
    obs_repro.repro,
  	obs_methode_loc.methode_loc,
  	obs_sociabilite.sociabilite,
  	obs_comportement.comportement,
  	obs_methode_obs.methode_obs,
  	obs_etat_bio.etat_bio,
  	obs_etat_sante.etat_sante,
  	rnf_obse.obse_multicr,
  	rnf_obse.obse_bague,
  	rnf_obse.obse_comment,
  	rnf_obse.obse_crea_dath,
  	rnf_obse.obse_lmod_dath,
  	CASE WHEN rnf_obse.obse_alt = '0' THEN NULL 
  		ELSE round(rnf_obse.obse_alt::numeric)::integer END as altitude,
      obs_geom.source_geom,
      obs_geom.geom_pt::geometry(POINT,2154) AS geom
   FROM _import_serena.rnf_obse
     LEFT JOIN obs_obsv ON rnf_obse.obse_obsv_id = obs_obsv.obse_obsv_id
     LEFT JOIN obs_deter ON rnf_obse.obse_detm_id = obs_deter.obse_detm_id
     JOIN obs_taxon ON rnf_obse.obse_taxo_id = obs_taxon.taxo_id
     LEFT JOIN obs_prot ON rnf_obse.obse_pcole_choi_id = obs_prot.obse_pcole_choi_id
     LEFT JOIN obs_valid ON rnf_obse.obse_validat_choi_id = obs_valid.obse_validat_choi_id
     LEFT JOIN obs_confid ON rnf_obse.obse_confid_choi_id = obs_confid.obse_confid_choi_id
     LEFT JOIN obs_type_denombr ON rnf_obse.obse_precis_choi_id = obs_type_denombr.obse_precis_choi_id
     LEFT JOIN obs_sexe ON rnf_obse.obse_sex_choi_id = obs_sexe.obse_sex_choi_id
     LEFT JOIN obs_stadevie ON rnf_obse.obse_stade_choi_id = obs_stadevie.obse_stade_choi_id
     LEFT JOIN obs_age_unite ON rnf_obse.obse_ageunit_choi_id = obs_age_unite.obse_ageunit_choi_id
     LEFT JOIN obs_abond ON rnf_obse.obse_abond_choi_id = obs_abond.obse_abond_choi_id
     LEFT JOIN obs_statubio ON rnf_obse.obse_activ_choi_id = obs_statubio.obse_activ_choi_id
     LEFT JOIN obs_repro ON rnf_obse.obse_caract_choi_id = obs_repro.obse_caract_choi_id
  	 LEFT JOIN obs_methode_loc ON rnf_obse.obse_methloc_choi_id = obs_methode_loc.obse_methloc_choi_id
  	 LEFT JOIN obs_sociabilite ON rnf_obse.obse_soci_choi_id = obs_sociabilite.obse_soci_choi_id
  	 LEFT JOIN obs_comportement ON rnf_obse.obse_comp_choi_id = obs_comportement.obse_comp_choi_id 
  	 LEFT JOIN obs_methode_obs ON rnf_obse.obse_contact_choi_id = obs_methode_obs.obse_contact_choi_id
  	 LEFT JOIN obs_etat_bio ON rnf_obse.obse_contact2_choi_id = obs_etat_bio.obse_contact2_choi_id
  	 LEFT JOIN obs_etat_sante ON rnf_obse.obse_etat_choi_id = obs_etat_sante.obse_etat_choi_id
  	 JOIN obs_geom ON rnf_obse.obse_id = obs_geom.obse_id
     LEFT JOIN _import_serena.rnf_taxo ON rnf_obse.obse_taxo_id=rnf_taxo.taxo_id
  WHERE rnf_obse.obse_validat_choi_id <> 100375
WITH DATA;

ALTER TABLE _import_serena.vm_obs_serena_detail_point
  OWNER TO serenadmin;
GRANT ALL ON TABLE _import_serena.vm_obs_serena_detail_point TO serenadmin;
GRANT ALL ON TABLE _import_serena.vm_obs_serena_detail_point TO geonatadmin
;

-- DROP INDEX _import_serena.vm_obs_serena_detail_point_geom;

CREATE INDEX vm_obs_serena_detail_point_geom
  ON _import_serena.vm_obs_serena_detail_point
  USING gist
  (geom);

-- DROP INDEX _import_serena.vm_obs_serena_detail_point_obsid;

CREATE INDEX vm_obs_serena_detail_point_obsid
  ON _import_serena.vm_obs_serena_detail_point
  USING btree
  (obse_id);

