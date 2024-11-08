-----------------------------------------------------
-- View: gn_exports.mv_grilles_pag 
-- ==> grilles ne couvrant que la surface du PAG (qui nous interresse)
-----------------------------------------------------

CREATE MATERIALIZED VIEW IF NOT EXISTS gn_exports.mv_grilles_territoire
TABLESPACE pg_default
AS
 SELECT l_areas.id_type,
    l_areas.area_name,
    l_areas.geom AS geom_grille_territoire
   FROM ref_geo.l_areas
     JOIN ( SELECT st_union(l_areas_1.geom) AS geom_territoire
           FROM ref_geo.l_areas l_areas_1
          WHERE l_areas_1.id_type = ANY (ARRAY[38])) territoire ON st_intersects(l_areas.geom, territoire.geom_territoire)
  WHERE l_areas.id_type = ANY (ARRAY[27, 28, 29])
WITH DATA;



-----------------------------------------------------
-- View: gn_exports.v_bilan_taxo_maille10x10_PAG
-- ==> Informations maillées sur le territoire du PAG, par groupe taxo
-- ==> Les statuts sont récupérés depuis la vue taxonomie.v_bdc_status (et non bdc_statuts qui liste tout) qui liste les statuts "actifs" d'un territoire
-- ==> Adapter les filtres des statuts de protection selon les territoires!
-- ==> Adapter le filtre des mailles selon échelle désirée
-----------------------------------------------------

DROP VIEW gn_exports."v_bilan_taxo_maille10x10_territoire";

CREATE VIEW gn_exports."v_bilan_taxo_maille10x10_territoire"
 AS
  WITH ref_taxo AS (
         SELECT DISTINCT 
	 		t.cd_nom,
            ref.cd_ref,
            ref.nom_complet,
            ref.nom_valide,
            ref.nom_vern,
            ref.group1_inpn,
            ref.group2_inpn,
            ref.regne,
            ref.phylum,
            ref.classe,
            ref.ordre,
            ref.famille,
            ref.id_rang
           FROM gn_synthese.synthese s
             JOIN taxonomie.taxref t ON s.cd_nom = t.cd_nom
             JOIN taxonomie.taxref ref ON t.cd_ref = ref.cd_nom
        ),
	liste_taxons AS (
		SELECT (ref_taxo.regne::text || ref_taxo.group2_inpn::text) || mv_grilles_territoire.area_name::text AS ref_geo_group,			
            ref_taxo.regne,
            ref_taxo.group2_inpn,
            mv_grilles_territoire.area_name,
            ref_taxo.cd_ref,
            mv_grilles_territoire.geom_grille_territoire,
            pat.cd_type_statut AS patrimonial,
            pr.cd_type_statut AS protection_stricte,
            menacemond.cd_type_statut AS menace_monde,
            menacereg.cd_type_statut AS menace_reg,
			sensreg.cd_type_statut AS sens_reg
           FROM gn_synthese.synthese
             JOIN ref_taxo ON synthese.cd_nom = ref_taxo.cd_nom
             JOIN gn_exports.mv_grilles_territoire ON st_intersects(synthese.the_geom_local, mv_grilles_territoire.geom_grille_territoire)
             LEFT JOIN taxonomie.v_bdc_status pat ON pat.cd_ref = ref_taxo.cd_ref AND pat.cd_type_statut = 'ZDET'
             LEFT JOIN taxonomie.v_bdc_status pr ON pr.cd_ref = ref_taxo.cd_ref AND pr.code_statut = ANY (ARRAY['GUYM1', 'GUYM3', 'DV973','GFAmRep2', 'GFAmRep3', 'GO2', 'GO3']) 
             LEFT JOIN taxonomie.v_bdc_status menacemond ON menacemond.cd_ref = ref_taxo.cd_ref AND menacemond.cd_type_statut = 'LRM' and menacemond.code_statut = ANY (ARRAY['EX', 'EW', 'CR','EN', 'VU']) 
             LEFT JOIN taxonomie.v_bdc_status menacereg ON menacereg.cd_ref = ref_taxo.cd_ref AND menacereg.cd_type_statut = 'LRR' and menacereg.code_statut = ANY (ARRAY['EX', 'EW', 'CR','EN', 'VU'])
			 LEFT JOIN taxonomie.v_bdc_status sensreg ON sensreg.cd_ref = ref_taxo.cd_ref AND sensreg.cd_type_statut = 'SENSREG'
          WHERE 
          --(synthese.id_nomenclature_valid_status = ANY (ARRAY[315, 316, 458])) AND 
          mv_grilles_territoire.id_type = 27
          GROUP BY ref_taxo.regne, ref_taxo.group2_inpn, mv_grilles_territoire.area_name, ref_taxo.cd_ref, mv_grilles_territoire.geom_grille_territoire, 
				pat.cd_type_statut, pr.cd_type_statut, menacemond.cd_type_statut, menacereg.cd_type_statut,sensreg.cd_type_statut
        ),
	stat_mailles_nb_data as (
		SELECT (ref_taxo.regne::text || ref_taxo.group2_inpn::text) || mv_grilles_territoire.area_name::text AS ref_geo_group,			
			ref_taxo.regne,
			ref_taxo.group2_inpn,
			mv_grilles_territoire.area_name,
			mv_grilles_territoire.geom_grille_territoire,
			count(*) as nb_data
		   FROM gn_synthese.synthese
			 JOIN ref_taxo ON synthese.cd_nom = ref_taxo.cd_nom
			 JOIN gn_exports.mv_grilles_territoire ON st_intersects(synthese.the_geom_local, mv_grilles_territoire.geom_grille_territoire)
		  WHERE 
--		  (synthese.id_nomenclature_valid_status = ANY (ARRAY[315, 316, 458])) AND 
		  mv_grilles_territoire.id_type = 27
		  GROUP BY ref_taxo.regne, ref_taxo.group2_inpn, mv_grilles_territoire.area_name, mv_grilles_territoire.geom_grille_territoire
        ),
	stat_mailles_nb_jdd AS (
		SELECT refs_jdd.ref_geo_group,			
			refs_jdd.regne,
			refs_jdd.group2_inpn,
			refs_jdd.area_name,
			refs_jdd.geom_grille_territoire,
			count(*) as nb_jdd
			FROM (SELECT DISTINCT (ref_taxo.regne::text || ref_taxo.group2_inpn::text) || mv_grilles_territoire.area_name::text AS ref_geo_group,			
				ref_taxo.regne,
				ref_taxo.group2_inpn,
				mv_grilles_territoire.area_name,
				mv_grilles_territoire.geom_grille_territoire,
				synthese.id_dataset
			   FROM gn_synthese.synthese
				 JOIN ref_taxo ON synthese.cd_nom = ref_taxo.cd_nom
				 JOIN gn_exports.mv_grilles_territoire ON st_intersects(synthese.the_geom_local, mv_grilles_territoire.geom_grille_territoire)
			  WHERE 
			  --(synthese.id_nomenclature_valid_status = ANY (ARRAY[315, 316, 458])) AND 
			  mv_grilles_territoire.id_type = 27) AS refs_jdd
		  GROUP BY refs_jdd.ref_geo_group, refs_jdd.regne, refs_jdd.group2_inpn, refs_jdd.area_name, refs_jdd.geom_grille_territoire
		),
	stat_mailles_nb_jours AS (		  
		SELECT refs_prospe.ref_geo_group, 
				refs_prospe.regne,
				refs_prospe.group2_inpn,
				refs_prospe.area_name,
				refs_prospe.geom_grille_territoire,
				count(*) as nb_jours_prospe
			FROM (SELECT DISTINCT (ref_taxo.regne::text || ref_taxo.group2_inpn::text) || mv_grilles_territoire.area_name::text AS ref_geo_group,			
				ref_taxo.regne,
				ref_taxo.group2_inpn,
				mv_grilles_territoire.area_name,
				mv_grilles_territoire.geom_grille_territoire,
				date_min				
			   FROM gn_synthese.synthese
				 JOIN ref_taxo ON synthese.cd_nom = ref_taxo.cd_nom
				 JOIN gn_exports.mv_grilles_territoire ON st_intersects(synthese.the_geom_local, mv_grilles_territoire.geom_grille_territoire)
			  WHERE 
			  --(synthese.id_nomenclature_valid_status = ANY (ARRAY[315, 316, 458])) AND 
			  mv_grilles_territoire.id_type = 27) as refs_prospe
			GROUP BY refs_prospe.ref_geo_group, 
				refs_prospe.regne,
				refs_prospe.group2_inpn,
				refs_prospe.area_name,
				refs_prospe.geom_grille_territoire
	)
 SELECT liste_refs_tot.area_name,
    liste_refs_tot.regne,
    liste_refs_tot.group2_inpn,
	stat_mailles_nb_data.nb_data,
	stat_mailles_nb_jdd.nb_jdd,
	stat_mailles_nb_jours.nb_jours_prospe,
    liste_refs_tot.nb_taxons_total,
	liste_refs_a_statut.nb_taxons_a_statut,
    liste_refs_prot.nb_taxons_proteges,
    liste_refs_patri.nb_taxons_znieff,
    liste_refs_menmond.nb_taxons_menaces_mond,
    liste_refs_menreg.nb_taxons_menaces_reg,
	liste_refs_sensreg.nb_taxons_sensreg,
    liste_refs_tot.geom_grille_territoire
   FROM ( SELECT liste_taxons.ref_geo_group,
            liste_taxons.area_name,
            liste_taxons.geom_grille_territoire,
            liste_taxons.regne,
            liste_taxons.group2_inpn,
            count(*) AS nb_taxons_total
           FROM liste_taxons
          GROUP BY liste_taxons.ref_geo_group, liste_taxons.area_name, liste_taxons.geom_grille_territoire, liste_taxons.regne, liste_taxons.group2_inpn) liste_refs_tot
	 LEFT JOIN stat_mailles_nb_data ON liste_refs_tot.ref_geo_group = stat_mailles_nb_data.ref_geo_group
	 LEFT JOIN stat_mailles_nb_jdd ON liste_refs_tot.ref_geo_group = stat_mailles_nb_jdd.ref_geo_group
	 LEFT JOIN stat_mailles_nb_jours ON liste_refs_tot.ref_geo_group = stat_mailles_nb_jours.ref_geo_group
	 LEFT JOIN ( SELECT liste_taxons.ref_geo_group,
            count(*) AS nb_taxons_a_statut
           FROM liste_taxons
          WHERE liste_taxons.protection_stricte is not null
				or liste_taxons.patrimonial is not null
				or liste_taxons.menace_monde is not null
				or liste_taxons.menace_reg is not null
				or liste_taxons.sens_reg is not null
          GROUP BY liste_taxons.ref_geo_group) liste_refs_a_statut ON liste_refs_tot.ref_geo_group = liste_refs_a_statut.ref_geo_group	  
     LEFT JOIN ( SELECT liste_taxons.ref_geo_group,
            count(*) AS nb_taxons_proteges
           FROM liste_taxons
          WHERE liste_taxons.protection_stricte is not null
          GROUP BY liste_taxons.ref_geo_group) liste_refs_prot ON liste_refs_tot.ref_geo_group = liste_refs_prot.ref_geo_group
     LEFT JOIN ( SELECT liste_taxons.ref_geo_group,
            count(*) AS nb_taxons_znieff
           FROM liste_taxons
          WHERE liste_taxons.patrimonial  is not null
          GROUP BY liste_taxons.ref_geo_group) liste_refs_patri ON liste_refs_tot.ref_geo_group = liste_refs_patri.ref_geo_group
     LEFT JOIN ( SELECT liste_taxons.ref_geo_group,
            count(*) AS nb_taxons_menaces_mond
           FROM liste_taxons
          WHERE liste_taxons.menace_monde  is not null
          GROUP BY liste_taxons.ref_geo_group) liste_refs_menmond ON liste_refs_tot.ref_geo_group = liste_refs_menmond.ref_geo_group
     LEFT JOIN ( SELECT liste_taxons.ref_geo_group,
            count(*) AS nb_taxons_menaces_reg
           FROM liste_taxons
          WHERE liste_taxons.menace_reg  is not null
          GROUP BY liste_taxons.ref_geo_group) liste_refs_menreg ON liste_refs_tot.ref_geo_group = liste_refs_menreg.ref_geo_group
		  LEFT JOIN ( SELECT liste_taxons.ref_geo_group,
            count(*) AS nb_taxons_sensreg
           FROM liste_taxons
          WHERE liste_taxons.sens_reg  is not null
          GROUP BY liste_taxons.ref_geo_group) liste_refs_sensreg ON liste_refs_tot.ref_geo_group = liste_refs_sensreg.ref_geo_group
  GROUP BY liste_refs_tot.area_name, liste_refs_tot.regne, liste_refs_tot.group2_inpn,
	stat_mailles_nb_data.nb_data, stat_mailles_nb_jdd.nb_jdd, stat_mailles_nb_jours.nb_jours_prospe,
  	liste_refs_tot.nb_taxons_total, liste_refs_a_statut.nb_taxons_a_statut,
	liste_refs_prot.nb_taxons_proteges, liste_refs_patri.nb_taxons_znieff, 
	liste_refs_menmond.nb_taxons_menaces_mond, liste_refs_menreg.nb_taxons_menaces_reg, 
	liste_refs_tot.geom_grille_territoire, liste_refs_sensreg.nb_taxons_sensreg
  ORDER BY liste_refs_tot.area_name, liste_refs_tot.regne, liste_refs_tot.group2_inpn;

-- ALTER TABLE gn_exports."v_bilan_taxo_maille10x10_PAG"
--    OWNER TO gnpag;
COMMENT ON VIEW gn_exports."v_bilan_taxo_maille10x10_territoire"
    IS 'Statistiques par maille de 10km (total, protégé, etc).
	Détail selon groupe taxonomique (données validées, probables ou en attente de validation). Tous les jeux de données sont exploités (dont partenariaux).';
COMMENT ON COLUMN gn_exports."v_bilan_taxo_maille10x10_territoire".area_name IS 'Nom de la maille'; 
COMMENT ON COLUMN gn_exports."v_bilan_taxo_maille10x10_territoire".regne IS 'Regne'; 
COMMENT ON COLUMN gn_exports."v_bilan_taxo_maille10x10_territoire".group2_inpn IS 'Groupe taxonomique (group2_inpn)'; 
COMMENT ON COLUMN gn_exports."v_bilan_taxo_maille10x10_territoire".nb_data IS 'Nombre de données sur la maille pour le groupe taxonomique désigné'; 
COMMENT ON COLUMN gn_exports."v_bilan_taxo_maille10x10_territoire".nb_jdd IS 'Nombre de jeux de données sur la maille pour le groupe taxonomique désigné'; 
COMMENT ON COLUMN gn_exports."v_bilan_taxo_maille10x10_territoire".nb_jours_prospe IS 'Nombre de jours sur la maille pour le groupe taxonomique désigné'; 
COMMENT ON COLUMN gn_exports."v_bilan_taxo_maille10x10_territoire".nb_taxons_total IS 'Nombre de taxons (tous niveau confondus) sur la maille pour le groupe taxonomique désigné'; 
COMMENT ON COLUMN gn_exports."v_bilan_taxo_maille10x10_territoire".nb_taxons_a_statut IS 'Nombre de taxons ayant un statut de protection/menace/znieff/sensibilité (tous niveau confondus) sur la maille pour le groupe taxonomique désigné'; 
COMMENT ON COLUMN gn_exports."v_bilan_taxo_maille10x10_territoire".nb_taxons_proteges IS 'Nombre de taxons à protection stricte (tous niveau confondus) sur la maille pour le groupe taxonomique désigné'; 
COMMENT ON COLUMN gn_exports."v_bilan_taxo_maille10x10_territoire".nb_taxons_znieff IS 'Nombre de taxons déterminants ZNIEFF (tous niveau confondus) sur la maille pour le groupe taxonomique désigné'; 
COMMENT ON COLUMN gn_exports."v_bilan_taxo_maille10x10_territoire".nb_taxons_menaces_mond IS 'Nombre de taxons menacés mondialement (tous niveau confondus) sur la maille pour le groupe taxonomique désigné'; 
COMMENT ON COLUMN gn_exports."v_bilan_taxo_maille10x10_territoire".nb_taxons_menaces_reg IS 'Nombre de taxons menacés au niveau régional (tous niveau confondus) sur la maille pour le groupe taxonomique désigné'; 
COMMENT ON COLUMN gn_exports."v_bilan_taxo_maille10x10_territoire".nb_taxons_sensreg IS 'Nombre de taxons sensibles (tous niveau confondus) sur la maille pour le groupe taxonomique désigné'; 
COMMENT ON COLUMN gn_exports."v_bilan_taxo_maille10x10_territoire".geom_grille_territoire IS 'Geometrie'; 
