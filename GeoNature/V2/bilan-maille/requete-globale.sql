-----------------------------------------------------
-- View: gn_exports.mv_grilles_territoire 
-- ==> grilles ne couvrant que la surface du Parc (qui nous interresse)
-----------------------------------------------------
DROP MATERIALIZED VIEW IF EXISTS gn_exports.mv_grilles_territoire;
CREATE MATERIALIZED VIEW IF NOT EXISTS gn_exports.mv_grilles_territoire
TABLESPACE pg_default
AS
SELECT 
    l_areas.id_type,
    bat.type_code,
    l_areas.area_name,
    l_areas.geom AS geom_grille_territoire
FROM ref_geo.l_areas AS l_areas
JOIN ref_geo.bib_areas_types bat ON bat.id_type = l_areas.id_type 
JOIN ( 
    SELECT st_union(la.geom) AS geom_territoire
    FROM ref_geo.l_areas la
    JOIN ref_geo.bib_areas_types bat
    ON bat.id_type = la.id_type 
    WHERE bat.type_code IN ('ZC', 'AA' )
) territoire ON st_intersects(l_areas.geom, territoire.geom_territoire)
WHERE bat.type_code IN ('M1', 'M5', 'M10')
WITH DATA;

CREATE INDEX IF NOT EXISTS index_gist_mv_grilles_territoire_geom_grille_territoire ON gn_exports.mv_grilles_territoire USING gist (geom_grille_territoire); 

-----------------------------------------------------
-- View: gn_exports.v_bilan_taxo_maille10x10_territoire
-- ==> Informations maillées sur le territoire, par groupe taxo
-- ==> Les statuts sont récupérés depuis la vue taxonomie.v_bdc_status (et non bdc_statuts qui liste tout) qui liste les statuts "actifs" d'un territoire
-- ==> Adapter les filtres des statuts de protection selon les territoires!
-- ==> Adapter le filtre des mailles selon échelle désirée
-- ==> Limiter les donnes selon le niveau de validation désiré dans st_validation
---------------------> Dispo ci-après: déclinaisons pour stats globales, animalia, plantae et pungi
-----------------------------------------------------

-- DROP VIEW gn_exports.v_bilan_taxo_maille10x10_territoire;

CREATE OR REPLACE VIEW gn_exports.v_bilan_taxo_maille10x10_territoire AS 
WITH   
    st_validation AS (      
        SELECT tn.id_nomenclature, tn.label_default, tn.mnemonique, tn.cd_nomenclature 
        FROM ref_nomenclatures.bib_nomenclatures_types bnt 
        JOIN ref_nomenclatures.t_nomenclatures tn 
        ON tn.id_type = bnt.id_type 
        WHERE bnt.mnemonique = 'STATUT_VALID' AND tn.cd_nomenclature IN ('1', '2', '6')
    ), sdata AS (
        -- Par défaut toutes les données de la synthèse valide
        --     En fonction des besoins rajouter des filtres
        SELECT t.cd_ref, t.regne, t.group2_inpn AS groupe_taxonomique, s.cd_nom, m.area_name, m.geom_grille_territoire, s.id_dataset, s.date_min, s.id_synthese
        FROM gn_synthese.synthese s
         JOIN taxonomie.taxref t ON s.cd_nom = t.cd_nom
        JOIN st_validation ON s.id_nomenclature_valid_status = st_validation.id_nomenclature
        JOIN gn_exports.mv_grilles_territoire m ON st_intersects(s.the_geom_local, m.geom_grille_territoire) AND  m.type_code = 'M10'   
  ), ref_taxo_status AS (
          SELECT 
              REF.cd_ref,
            array_remove(array_agg(pat.cd_type_statut), NULL) AS patrimonial,
            array_remove(array_agg(pr.cd_type_statut), NULL)  AS protection_stricte,
            array_remove(array_agg(menacemond.cd_type_statut), NULL)  AS menace_monde,
            array_remove(array_agg(menacereg.cd_type_statut), NULL)  AS menace_reg,
            array_remove(array_agg(sensreg.cd_type_statut), NULL)  AS sens_reg
          FROM taxonomie.taxref ref
        LEFT JOIN taxonomie.v_bdc_status pat ON pat.cd_ref = ref.cd_ref AND pat.cd_type_statut::text = 'ZDET'::text
        LEFT JOIN taxonomie.v_bdc_status pr ON pr.cd_ref = ref.cd_nom AND (pr.code_statut::text = ANY (ARRAY['GUYM1'::text, 'GUYM3'::text, 'DV973'::text, 'GFAmRep2'::text, 'GFAmRep3'::text, 'GO2'::text, 'GO3'::text]))
        LEFT JOIN taxonomie.v_bdc_status menacemond ON menacemond.cd_ref = ref.cd_nom AND menacemond.cd_type_statut::text = 'LRM'::text AND (menacemond.code_statut::text = ANY (ARRAY['EX'::text, 'EW'::text, 'CR'::text, 'EN'::text, 'VU'::text]))
        LEFT JOIN taxonomie.v_bdc_status menacereg ON menacereg.cd_ref = ref.cd_nom AND menacereg.cd_type_statut::text = 'LRR'::text AND (menacereg.code_statut::text = ANY (ARRAY['EX'::text, 'EW'::text, 'CR'::text, 'EN'::text, 'VU'::text]))
        LEFT JOIN taxonomie.v_bdc_status sensreg ON sensreg.cd_ref = ref.cd_nom AND sensreg.cd_type_statut::text = 'SENSREG'::text
        GROUP BY  REF.cd_ref
        ) 
         SELECT row_number() over(order by s.area_name, s.regne, s.groupe_taxonomique) as bilan_id,
            s.area_name,
            s.regne,  
            s.groupe_taxonomique,
            count(DISTINCT s.id_synthese) AS nb_data,
            count(DISTINCT s.id_dataset)  AS nb_jdd,
            count(DISTINCT s.date_min::date) AS nb_jours_prospe, 
            count(DISTINCT s.cd_ref) AS nb_taxons_total,
            count(DISTINCT s.cd_ref)  FILTER ( WHERE  
                st.protection_stricte IS NOT NULL 
                OR st.patrimonial IS NOT NULL 
                OR st.menace_monde IS NOT NULL 
                OR st.menace_reg IS NOT NULL 
                OR st.sens_reg IS NOT NULL
            ) AS nb_taxons_a_statut,
            count(DISTINCT s.cd_ref)  FILTER ( WHERE  st.protection_stricte IS NOT NULL ) AS   nb_taxons_proteges,
            count(DISTINCT s.cd_ref)  FILTER ( WHERE  st.patrimonial IS NOT NULL ) AS   nb_taxons_znieff,
            count(DISTINCT s.cd_ref)  FILTER ( WHERE  st.menace_monde IS NOT NULL ) AS   nb_taxons_menaces_mond,
            count(DISTINCT s.cd_ref)  FILTER ( WHERE  st.menace_reg IS NOT NULL ) AS   nb_taxons_menaces_reg,
            count(DISTINCT s.cd_ref)  FILTER ( WHERE  st.sens_reg IS NOT NULL ) AS   nb_taxons_sensreg ,
            s.geom_grille_territoire
           FROM sdata s 
           JOIN ref_taxo_status st ON st.cd_ref = s.cd_ref
           GROUP BY s.regne, 
                s.groupe_taxonomique,
                s.area_name,
                s.geom_grille_territoire;

-- ALTER TABLE gn_exports.v_bilan_taxo_maille10x10_territoire OWNER TO gnpag;
COMMENT ON VIEW gn_exports.v_bilan_taxo_maille10x10_territoire IS 'Statistiques par maille de 10km (total, protégé, etc), tous groupes taxonomiques confondus (données validées, probables ou en attente de validation). Tous les jeux de données sont exploités (dont partenariaux).';
COMMENT ON COLUMN gn_exports.v_bilan_taxo_maille10x10_territoire.bilan_id IS 'Identifiant';
COMMENT ON COLUMN gn_exports.v_bilan_taxo_maille10x10_territoire.area_name IS 'Nom de la maille';
COMMENT ON COLUMN gn_exports.v_bilan_taxo_maille10x10_territoire.regne IS 'Tous règnes confondus';
COMMENT ON COLUMN gn_exports.v_bilan_taxo_maille10x10_territoire.groupe_taxonomique IS 'Tous groupes confondus';
COMMENT ON COLUMN gn_exports.v_bilan_taxo_maille10x10_territoire.nb_data IS 'Nombre de données sur la maille';
COMMENT ON COLUMN gn_exports.v_bilan_taxo_maille10x10_territoire.nb_jdd IS 'Nombre de jeux de données sur la maille';
COMMENT ON COLUMN gn_exports.v_bilan_taxo_maille10x10_territoire.nb_jours_prospe IS 'Nombre de jours sur la maille';
COMMENT ON COLUMN gn_exports.v_bilan_taxo_maille10x10_territoire.nb_taxons_total IS 'Nombre de taxons (tous niveau confondus) sur la maille';
COMMENT ON COLUMN gn_exports.v_bilan_taxo_maille10x10_territoire.nb_taxons_a_statut IS 'Nombre de taxons ayant un statut de protection/menace/znieff/sensibilité (tous niveau confondus) sur la maille';
COMMENT ON COLUMN gn_exports.v_bilan_taxo_maille10x10_territoire.nb_taxons_proteges IS 'Nombre de taxons à protection stricte (tous niveau confondus) sur la maille';
COMMENT ON COLUMN gn_exports.v_bilan_taxo_maille10x10_territoire.nb_taxons_znieff IS 'Nombre de taxons déterminants ZNIEFF (tous niveau confondus) sur la maille';
COMMENT ON COLUMN gn_exports.v_bilan_taxo_maille10x10_territoire.nb_taxons_menaces_mond IS 'Nombre de taxons menacés mondialement (tous niveau confondus) sur la maille';
COMMENT ON COLUMN gn_exports.v_bilan_taxo_maille10x10_territoire.nb_taxons_menaces_reg IS 'Nombre de taxons menacés au niveau régional (tous niveau confondus) sur la maille';
COMMENT ON COLUMN gn_exports.v_bilan_taxo_maille10x10_territoire.nb_taxons_sensreg IS 'Nombre de taxons sensibles (tous niveau confondus) sur la maille';
COMMENT ON COLUMN gn_exports.v_bilan_taxo_maille10x10_territoire.geom_grille_territoire IS 'Geometrie';


------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------- View: gn_exports.v_bilan_taxo_maille10x10_global
------------------------------------------------------------------------------------------------------------------------------------------------------
--DROP VIEW gn_exports.v_bilan_taxo_maille10x10_global;

CREATE OR REPLACE VIEW gn_exports.v_bilan_taxo_maille10x10_global
 AS
 WITH 
    st_validation AS (      
        SELECT tn.id_nomenclature, tn.label_default, tn.mnemonique, tn.cd_nomenclature 
        FROM ref_nomenclatures.bib_nomenclatures_types bnt 
        JOIN ref_nomenclatures.t_nomenclatures tn 
        ON tn.id_type = bnt.id_type 
        WHERE bnt.mnemonique = 'STATUT_VALID' AND tn.cd_nomenclature IN ('1', '2', '6')
    ),
    ref_taxo AS (
         SELECT DISTINCT t.cd_nom,
            ref.cd_ref,
            ref.nom_complet,
            ref.nom_valide,
            ref.nom_vern,
            ref.group1_inpn,
            'Tous groupes confondus'::text AS groupe_taxonomique,
            'Tous regnes'::text AS regne,
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
         SELECT (ref_taxo.regne || ref_taxo.groupe_taxonomique) || mv_grilles_territoire.area_name::text AS ref_geo_group,
            ref_taxo.regne,
            ref_taxo.groupe_taxonomique,
            mv_grilles_territoire.area_name,
            ref_taxo.cd_ref,
            mv_grilles_territoire.geom_grille_territoire,
            pat.cd_type_statut AS patrimonial,
            pr.cd_type_statut AS protection_stricte,
            menacemond.cd_type_statut AS menace_monde,
            menacereg.cd_type_statut AS menace_reg,
            sensreg.cd_type_statut AS sens_reg
           FROM gn_synthese.synthese JOIN st_validation ON synthese.id_nomenclature_valid_status = st_validation.id_nomenclature
             JOIN ref_taxo ON synthese.cd_nom = ref_taxo.cd_nom
             JOIN gn_exports.mv_grilles_territoire ON st_intersects(synthese.the_geom_local, mv_grilles_territoire.geom_grille_territoire)
             LEFT JOIN taxonomie.v_bdc_status pat ON pat.cd_ref = ref_taxo.cd_ref AND pat.cd_type_statut::text = 'ZDET'::text
             LEFT JOIN taxonomie.v_bdc_status pr ON pr.cd_ref = ref_taxo.cd_ref AND (pr.code_statut::text = ANY (ARRAY['GUYM1'::text, 'GUYM3'::text, 'DV973'::text, 'GFAmRep2'::text, 'GFAmRep3'::text, 'GO2'::text, 'GO3'::text]))
             LEFT JOIN taxonomie.v_bdc_status menacemond ON menacemond.cd_ref = ref_taxo.cd_ref AND menacemond.cd_type_statut::text = 'LRM'::text AND (menacemond.code_statut::text = ANY (ARRAY['EX'::text, 'EW'::text, 'CR'::text, 'EN'::text, 'VU'::text]))
             LEFT JOIN taxonomie.v_bdc_status menacereg ON menacereg.cd_ref = ref_taxo.cd_ref AND menacereg.cd_type_statut::text = 'LRR'::text AND (menacereg.code_statut::text = ANY (ARRAY['EX'::text, 'EW'::text, 'CR'::text, 'EN'::text, 'VU'::text]))
             LEFT JOIN taxonomie.v_bdc_status sensreg ON sensreg.cd_ref = ref_taxo.cd_ref AND sensreg.cd_type_statut::text = 'SENSREG'::text
          WHERE mv_grilles_territoire.type_code = 'M10'
          GROUP BY ref_taxo.regne, ref_taxo.groupe_taxonomique, mv_grilles_territoire.area_name, ref_taxo.cd_ref, mv_grilles_territoire.geom_grille_territoire, pat.cd_type_statut, pr.cd_type_statut, menacemond.cd_type_statut, menacereg.cd_type_statut, sensreg.cd_type_statut
        ), 
    stat_mailles_nb_data AS (
         SELECT (ref_taxo.regne || ref_taxo.groupe_taxonomique) || mv_grilles_territoire.area_name::text AS ref_geo_group,
            ref_taxo.regne,
            ref_taxo.groupe_taxonomique,
            mv_grilles_territoire.area_name,
            mv_grilles_territoire.geom_grille_territoire,
            count(*) AS nb_data
           FROM gn_synthese.synthese JOIN st_validation ON synthese.id_nomenclature_valid_status = st_validation.id_nomenclature
             JOIN ref_taxo ON synthese.cd_nom = ref_taxo.cd_nom
             JOIN gn_exports.mv_grilles_territoire ON st_intersects(synthese.the_geom_local, mv_grilles_territoire.geom_grille_territoire)
          WHERE mv_grilles_territoire.type_code = 'M10'
          GROUP BY ref_taxo.regne, ref_taxo.groupe_taxonomique, mv_grilles_territoire.area_name, mv_grilles_territoire.geom_grille_territoire
        ), 
    stat_mailles_nb_jdd AS (
         SELECT refs_jdd.ref_geo_group,
            refs_jdd.regne,
            refs_jdd.groupe_taxonomique,
            refs_jdd.area_name,
            refs_jdd.geom_grille_territoire,
            count(*) AS nb_jdd
           FROM ( SELECT DISTINCT (ref_taxo.regne || ref_taxo.groupe_taxonomique) || mv_grilles_territoire.area_name::text AS ref_geo_group,
                    ref_taxo.regne,
                    ref_taxo.groupe_taxonomique,
                    mv_grilles_territoire.area_name,
                    mv_grilles_territoire.geom_grille_territoire,
                    synthese.id_dataset
                   FROM gn_synthese.synthese JOIN st_validation ON synthese.id_nomenclature_valid_status = st_validation.id_nomenclature
                     JOIN ref_taxo ON synthese.cd_nom = ref_taxo.cd_nom
                     JOIN gn_exports.mv_grilles_territoire ON st_intersects(synthese.the_geom_local, mv_grilles_territoire.geom_grille_territoire)
                  WHERE mv_grilles_territoire.type_code = 'M10') refs_jdd
          GROUP BY refs_jdd.ref_geo_group, refs_jdd.regne, refs_jdd.groupe_taxonomique, refs_jdd.area_name, refs_jdd.geom_grille_territoire
        ), 
    stat_mailles_nb_jours AS (
         SELECT refs_prospe.ref_geo_group,
            refs_prospe.regne,
            refs_prospe.groupe_taxonomique,
            refs_prospe.area_name,
            refs_prospe.geom_grille_territoire,
            count(*) AS nb_jours_prospe
           FROM ( SELECT DISTINCT (ref_taxo.regne || ref_taxo.groupe_taxonomique) || mv_grilles_territoire.area_name::text AS ref_geo_group,
                    ref_taxo.regne,
                    ref_taxo.groupe_taxonomique,
                    mv_grilles_territoire.area_name,
                    mv_grilles_territoire.geom_grille_territoire,
                    synthese.date_min
                   FROM gn_synthese.synthese JOIN st_validation ON synthese.id_nomenclature_valid_status = st_validation.id_nomenclature
                     JOIN ref_taxo ON synthese.cd_nom = ref_taxo.cd_nom
                     JOIN gn_exports.mv_grilles_territoire ON st_intersects(synthese.the_geom_local, mv_grilles_territoire.geom_grille_territoire)
                  WHERE mv_grilles_territoire.type_code = 'M10') refs_prospe
          GROUP BY refs_prospe.ref_geo_group, refs_prospe.regne, refs_prospe.groupe_taxonomique, refs_prospe.area_name, refs_prospe.geom_grille_territoire
        )
 SELECT row_number() over(order by liste_refs_tot.area_name, liste_refs_tot.regne, liste_refs_tot.groupe_taxonomique) as bilan_id,
     liste_refs_tot.area_name,
    liste_refs_tot.regne,
    liste_refs_tot.groupe_taxonomique,
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
            liste_taxons.groupe_taxonomique,
            count(*) AS nb_taxons_total
           FROM liste_taxons
          GROUP BY liste_taxons.ref_geo_group, liste_taxons.area_name, liste_taxons.geom_grille_territoire, liste_taxons.regne, liste_taxons.groupe_taxonomique) liste_refs_tot
     LEFT JOIN stat_mailles_nb_data ON liste_refs_tot.ref_geo_group = stat_mailles_nb_data.ref_geo_group
     LEFT JOIN stat_mailles_nb_jdd ON liste_refs_tot.ref_geo_group = stat_mailles_nb_jdd.ref_geo_group
     LEFT JOIN stat_mailles_nb_jours ON liste_refs_tot.ref_geo_group = stat_mailles_nb_jours.ref_geo_group
     LEFT JOIN ( SELECT liste_taxons.ref_geo_group,
            count(*) AS nb_taxons_a_statut
           FROM liste_taxons
          WHERE liste_taxons.protection_stricte IS NOT NULL OR liste_taxons.patrimonial IS NOT NULL OR liste_taxons.menace_monde IS NOT NULL OR liste_taxons.menace_reg IS NOT NULL OR liste_taxons.sens_reg IS NOT NULL
          GROUP BY liste_taxons.ref_geo_group) liste_refs_a_statut ON liste_refs_tot.ref_geo_group = liste_refs_a_statut.ref_geo_group
     LEFT JOIN ( SELECT liste_taxons.ref_geo_group,
            count(*) AS nb_taxons_proteges
           FROM liste_taxons
          WHERE liste_taxons.protection_stricte IS NOT NULL
          GROUP BY liste_taxons.ref_geo_group) liste_refs_prot ON liste_refs_tot.ref_geo_group = liste_refs_prot.ref_geo_group
     LEFT JOIN ( SELECT liste_taxons.ref_geo_group,
            count(*) AS nb_taxons_znieff
           FROM liste_taxons
          WHERE liste_taxons.patrimonial IS NOT NULL
          GROUP BY liste_taxons.ref_geo_group) liste_refs_patri ON liste_refs_tot.ref_geo_group = liste_refs_patri.ref_geo_group
     LEFT JOIN ( SELECT liste_taxons.ref_geo_group,
            count(*) AS nb_taxons_menaces_mond
           FROM liste_taxons
          WHERE liste_taxons.menace_monde IS NOT NULL
          GROUP BY liste_taxons.ref_geo_group) liste_refs_menmond ON liste_refs_tot.ref_geo_group = liste_refs_menmond.ref_geo_group
     LEFT JOIN ( SELECT liste_taxons.ref_geo_group,
            count(*) AS nb_taxons_menaces_reg
           FROM liste_taxons
          WHERE liste_taxons.menace_reg IS NOT NULL
          GROUP BY liste_taxons.ref_geo_group) liste_refs_menreg ON liste_refs_tot.ref_geo_group = liste_refs_menreg.ref_geo_group
     LEFT JOIN ( SELECT liste_taxons.ref_geo_group,
            count(*) AS nb_taxons_sensreg
           FROM liste_taxons
          WHERE liste_taxons.sens_reg IS NOT NULL
          GROUP BY liste_taxons.ref_geo_group) liste_refs_sensreg ON liste_refs_tot.ref_geo_group = liste_refs_sensreg.ref_geo_group
  GROUP BY liste_refs_tot.area_name, liste_refs_tot.regne, liste_refs_tot.groupe_taxonomique, stat_mailles_nb_data.nb_data, stat_mailles_nb_jdd.nb_jdd, stat_mailles_nb_jours.nb_jours_prospe, liste_refs_tot.nb_taxons_total, liste_refs_a_statut.nb_taxons_a_statut, liste_refs_prot.nb_taxons_proteges, liste_refs_patri.nb_taxons_znieff, liste_refs_menmond.nb_taxons_menaces_mond, liste_refs_menreg.nb_taxons_menaces_reg, liste_refs_tot.geom_grille_territoire, liste_refs_sensreg.nb_taxons_sensreg
  ORDER BY liste_refs_tot.area_name, liste_refs_tot.regne, liste_refs_tot.groupe_taxonomique;

--ALTER TABLE gn_exports.v_bilan_taxo_maille10x10_global OWNER TO gnpag;
COMMENT ON VIEW gn_exports.v_bilan_taxo_maille10x10_global IS 'Statistiques par maille de 10km (total, protégé, etc), tous groupes taxonomiques confondus (données validées, probables ou en attente de validation). Tous les jeux de données sont exploités (dont partenariaux).';
COMMENT ON COLUMN gn_exports.v_bilan_taxo_maille10x10_global.bilan_id IS 'Identifiant';
COMMENT ON COLUMN gn_exports.v_bilan_taxo_maille10x10_global.area_name IS 'Nom de la maille';
COMMENT ON COLUMN gn_exports.v_bilan_taxo_maille10x10_global.regne IS 'Tous règnes confondus';
COMMENT ON COLUMN gn_exports.v_bilan_taxo_maille10x10_global.groupe_taxonomique IS 'Tous groupes confondus';
COMMENT ON COLUMN gn_exports.v_bilan_taxo_maille10x10_global.nb_data IS 'Nombre de données sur la maille';
COMMENT ON COLUMN gn_exports.v_bilan_taxo_maille10x10_global.nb_jdd IS 'Nombre de jeux de données sur la maille';
COMMENT ON COLUMN gn_exports.v_bilan_taxo_maille10x10_global.nb_jours_prospe IS 'Nombre de jours sur la maille';
COMMENT ON COLUMN gn_exports.v_bilan_taxo_maille10x10_global.nb_taxons_total IS 'Nombre de taxons (tous niveau confondus) sur la maille';
COMMENT ON COLUMN gn_exports.v_bilan_taxo_maille10x10_global.nb_taxons_a_statut IS 'Nombre de taxons ayant un statut de protection/menace/znieff/sensibilité (tous niveau confondus) sur la maille';
COMMENT ON COLUMN gn_exports.v_bilan_taxo_maille10x10_global.nb_taxons_proteges IS 'Nombre de taxons à protection stricte (tous niveau confondus) sur la maille';
COMMENT ON COLUMN gn_exports.v_bilan_taxo_maille10x10_global.nb_taxons_znieff IS 'Nombre de taxons déterminants ZNIEFF (tous niveau confondus) sur la maille';
COMMENT ON COLUMN gn_exports.v_bilan_taxo_maille10x10_global.nb_taxons_menaces_mond IS 'Nombre de taxons menacés mondialement (tous niveau confondus) sur la maille';
COMMENT ON COLUMN gn_exports.v_bilan_taxo_maille10x10_global.nb_taxons_menaces_reg IS 'Nombre de taxons menacés au niveau régional (tous niveau confondus) sur la maille';
COMMENT ON COLUMN gn_exports.v_bilan_taxo_maille10x10_global.nb_taxons_sensreg IS 'Nombre de taxons sensibles (tous niveau confondus) sur la maille';
COMMENT ON COLUMN gn_exports.v_bilan_taxo_maille10x10_global.geom_grille_territoire IS 'Geometrie';

------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------  View: gn_exports.v_bilan_taxo_maille10x10_animalia
------------------------------------------------------------------------------------------------------------------------------------------------------
-- DROP VIEW gn_exports.v_bilan_taxo_maille10x10_animalia;

CREATE OR REPLACE VIEW gn_exports.v_bilan_taxo_maille10x10_animalia
 AS
WITH   
    st_validation AS (      
        SELECT tn.id_nomenclature, tn.label_default, tn.mnemonique, tn.cd_nomenclature 
        FROM ref_nomenclatures.bib_nomenclatures_types bnt 
        JOIN ref_nomenclatures.t_nomenclatures tn 
        ON tn.id_type = bnt.id_type 
        WHERE bnt.mnemonique = 'STATUT_VALID' AND tn.cd_nomenclature IN ('1', '2', '6')
    ), sdata AS (
        -- Par défaut toutes les données de la synthèse valide
        --     En fonction des besoins rajouter des filtres
      SELECT 
         t.cd_ref, t.regne, 
         CASE
            WHEN ref.group1_inpn::text = 'Chordés'::text THEN ref.group2_inpn
            ELSE 'Invertébrés'::character varying
         END AS groupe_taxonomique,
         s.cd_nom, m.area_name, m.geom_grille_territoire, s.id_dataset, s.date_min, s.id_synthese
      FROM gn_synthese.synthese s
         JOIN taxonomie.taxref t ON s.cd_nom = t.cd_nom
      JOIN st_validation ON s.id_nomenclature_valid_status = st_validation.id_nomenclature
      JOIN gn_exports.mv_grilles_territoire m ON st_intersects(s.the_geom_local, m.geom_grille_territoire) AND  m.type_code = 'M10'   
      WHERE t.regne = 'Animalia'
  ), ref_taxo_status AS (
      SELECT 
              REF.cd_ref,
            array_remove(array_agg(pat.cd_type_statut), NULL) AS patrimonial,
            array_remove(array_agg(pr.cd_type_statut), NULL)  AS protection_stricte,
            array_remove(array_agg(menacemond.cd_type_statut), NULL)  AS menace_monde,
            array_remove(array_agg(menacereg.cd_type_statut), NULL)  AS menace_reg,
            array_remove(array_agg(sensreg.cd_type_statut), NULL)  AS sens_reg
          FROM taxonomie.taxref ref
        LEFT JOIN taxonomie.v_bdc_status pat ON pat.cd_ref = ref.cd_ref AND pat.cd_type_statut::text = 'ZDET'::text
        LEFT JOIN taxonomie.v_bdc_status pr ON pr.cd_ref = ref.cd_nom AND (pr.code_statut::text = ANY (ARRAY['GUYM1'::text, 'GUYM3'::text, 'DV973'::text, 'GFAmRep2'::text, 'GFAmRep3'::text, 'GO2'::text, 'GO3'::text]))
        LEFT JOIN taxonomie.v_bdc_status menacemond ON menacemond.cd_ref = ref.cd_nom AND menacemond.cd_type_statut::text = 'LRM'::text AND (menacemond.code_statut::text = ANY (ARRAY['EX'::text, 'EW'::text, 'CR'::text, 'EN'::text, 'VU'::text]))
        LEFT JOIN taxonomie.v_bdc_status menacereg ON menacereg.cd_ref = ref.cd_nom AND menacereg.cd_type_statut::text = 'LRR'::text AND (menacereg.code_statut::text = ANY (ARRAY['EX'::text, 'EW'::text, 'CR'::text, 'EN'::text, 'VU'::text]))
        LEFT JOIN taxonomie.v_bdc_status sensreg ON sensreg.cd_ref = ref.cd_nom AND sensreg.cd_type_statut::text = 'SENSREG'::text
        GROUP BY  REF.cd_ref
        ) 
         SELECT row_number() over(order by s.area_name, s.regne, s.groupe_taxonomique) as bilan_id,
            s.area_name,
            s.regne,  
            s.groupe_taxonomique,
            count(DISTINCT s.id_synthese) AS nb_data,
            count(DISTINCT s.id_dataset)  AS nb_jdd,
            count(DISTINCT s.date_min::date) AS nb_jours_prospe, 
            count(DISTINCT s.cd_ref) AS nb_taxons_total,
            count(DISTINCT s.cd_ref)  FILTER ( WHERE  
                st.protection_stricte IS NOT NULL 
                OR st.patrimonial IS NOT NULL 
                OR st.menace_monde IS NOT NULL 
                OR st.menace_reg IS NOT NULL 
                OR st.sens_reg IS NOT NULL
            ) AS nb_taxons_a_statut,
            count(DISTINCT s.cd_ref)  FILTER ( WHERE  st.protection_stricte IS NOT NULL ) AS   nb_taxons_proteges,
            count(DISTINCT s.cd_ref)  FILTER ( WHERE  st.patrimonial IS NOT NULL ) AS   nb_taxons_znieff,
            count(DISTINCT s.cd_ref)  FILTER ( WHERE  st.menace_monde IS NOT NULL ) AS   nb_taxons_menaces_mond,
            count(DISTINCT s.cd_ref)  FILTER ( WHERE  st.menace_reg IS NOT NULL ) AS   nb_taxons_menaces_reg,
            count(DISTINCT s.cd_ref)  FILTER ( WHERE  st.sens_reg IS NOT NULL ) AS   nb_taxons_sensreg ,
            s.geom_grille_territoire
           FROM sdata s 
           JOIN ref_taxo_status st ON st.cd_ref = s.cd_ref
           GROUP BY s.regne, 
                s.groupe_taxonomique,
                s.area_name,
                s.geom_grille_territoire;


--ALTER TABLE gn_exports.v_bilan_taxo_maille10x10_animalia OWNER TO gnpag;
COMMENT ON VIEW gn_exports.v_bilan_taxo_maille10x10_animalia IS 'Statistiques par maille de 10km (total, protégé, etc). Détail selon groupe taxonomique (données validées, probables ou en attente de validation). Tous les jeux de données sont exploités (dont partenariaux).';
COMMENT ON COLUMN gn_exports.v_bilan_taxo_maille10x10_animalia.bilan_id IS 'Identifiant';
COMMENT ON COLUMN gn_exports.v_bilan_taxo_maille10x10_animalia.area_name IS 'Nom de la maille';
COMMENT ON COLUMN gn_exports.v_bilan_taxo_maille10x10_animalia.regne IS 'Regne';
COMMENT ON COLUMN gn_exports.v_bilan_taxo_maille10x10_animalia.groupe_taxonomique IS 'Groupe taxonomique (group2_inpn pour les chordés, sinon "Invertébrés")';
COMMENT ON COLUMN gn_exports.v_bilan_taxo_maille10x10_animalia.nb_data IS 'Nombre de données sur la maille pour le groupe taxonomique désigné';
COMMENT ON COLUMN gn_exports.v_bilan_taxo_maille10x10_animalia.nb_jdd IS 'Nombre de jeux de données sur la maille pour le groupe taxonomique désigné';
COMMENT ON COLUMN gn_exports.v_bilan_taxo_maille10x10_animalia.nb_jours_prospe IS 'Nombre de jours sur la maille pour le groupe taxonomique désigné';
COMMENT ON COLUMN gn_exports.v_bilan_taxo_maille10x10_animalia.nb_taxons_total IS 'Nombre de taxons (tous niveau confondus) sur la maille pour le groupe taxonomique désigné';
COMMENT ON COLUMN gn_exports.v_bilan_taxo_maille10x10_animalia.nb_taxons_a_statut IS 'Nombre de taxons ayant un statut de protection/menace/znieff/sensibilité (tous niveau confondus) sur la maille pour le groupe taxonomique désigné';
COMMENT ON COLUMN gn_exports.v_bilan_taxo_maille10x10_animalia.nb_taxons_proteges IS 'Nombre de taxons à protection stricte (tous niveau confondus) sur la maille pour le groupe taxonomique désigné';
COMMENT ON COLUMN gn_exports.v_bilan_taxo_maille10x10_animalia.nb_taxons_znieff IS 'Nombre de taxons déterminants ZNIEFF (tous niveau confondus) sur la maille pour le groupe taxonomique désigné';
COMMENT ON COLUMN gn_exports.v_bilan_taxo_maille10x10_animalia.nb_taxons_menaces_mond IS 'Nombre de taxons menacés mondialement (tous niveau confondus) sur la maille pour le groupe taxonomique désigné';
COMMENT ON COLUMN gn_exports.v_bilan_taxo_maille10x10_animalia.nb_taxons_menaces_reg IS 'Nombre de taxons menacés au niveau régional (tous niveau confondus) sur la maille pour le groupe taxonomique désigné';
COMMENT ON COLUMN gn_exports.v_bilan_taxo_maille10x10_animalia.nb_taxons_sensreg IS 'Nombre de taxons sensibles (tous niveau confondus) sur la maille pour le groupe taxonomique désigné';
COMMENT ON COLUMN gn_exports.v_bilan_taxo_maille10x10_animalia.geom_grille_territoire IS 'Geometrie';


------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------- View: gn_exports.v_bilan_taxo_maille10x10_plantae
------------------------------------------------------------------------------------------------------------------------------------------------------
-- DROP VIEW gn_exports.v_bilan_taxo_maille10x10_plantae;

CREATE OR REPLACE VIEW gn_exports.v_bilan_taxo_maille10x10_plantae
 AS
 WITH   
    st_validation AS (      
        SELECT tn.id_nomenclature, tn.label_default, tn.mnemonique, tn.cd_nomenclature 
        FROM ref_nomenclatures.bib_nomenclatures_types bnt 
        JOIN ref_nomenclatures.t_nomenclatures tn 
        ON tn.id_type = bnt.id_type 
        WHERE bnt.mnemonique = 'STATUT_VALID' AND tn.cd_nomenclature IN ('1', '2', '6')
    ), sdata AS (
        -- Par défaut toutes les données de la synthèse valide
        --     En fonction des besoins rajouter des filtres
        SELECT 
            t.cd_ref, t.regne, 
            ref.group2_inpn as groupe_taxonomique,
            s.cd_nom, m.area_name, m.geom_grille_territoire, s.id_dataset, s.date_min, s.id_synthese
        FROM gn_synthese.synthese s
            JOIN taxonomie.taxref t ON s.cd_nom = t.cd_nom
        JOIN st_validation ON s.id_nomenclature_valid_status = st_validation.id_nomenclature
        JOIN gn_exports.mv_grilles_territoire m ON st_intersects(s.the_geom_local, m.geom_grille_territoire) AND  m.type_code = 'M10'   
        WHERE ref.regne::text = 'Plantae'::text
  ), ref_taxo_status AS (
          SELECT 
              REF.cd_ref,
            array_remove(array_agg(pat.cd_type_statut), NULL) AS patrimonial,
            array_remove(array_agg(pr.cd_type_statut), NULL)  AS protection_stricte,
            array_remove(array_agg(menacemond.cd_type_statut), NULL)  AS menace_monde,
            array_remove(array_agg(menacereg.cd_type_statut), NULL)  AS menace_reg,
            array_remove(array_agg(sensreg.cd_type_statut), NULL)  AS sens_reg
          FROM taxonomie.taxref ref
        LEFT JOIN taxonomie.v_bdc_status pat ON pat.cd_ref = ref.cd_ref AND pat.cd_type_statut::text = 'ZDET'::text
        LEFT JOIN taxonomie.v_bdc_status pr ON pr.cd_ref = ref.cd_nom AND (pr.code_statut::text = ANY (ARRAY['GUYM1'::text, 'GUYM3'::text, 'DV973'::text, 'GFAmRep2'::text, 'GFAmRep3'::text, 'GO2'::text, 'GO3'::text]))
        LEFT JOIN taxonomie.v_bdc_status menacemond ON menacemond.cd_ref = ref.cd_nom AND menacemond.cd_type_statut::text = 'LRM'::text AND (menacemond.code_statut::text = ANY (ARRAY['EX'::text, 'EW'::text, 'CR'::text, 'EN'::text, 'VU'::text]))
        LEFT JOIN taxonomie.v_bdc_status menacereg ON menacereg.cd_ref = ref.cd_nom AND menacereg.cd_type_statut::text = 'LRR'::text AND (menacereg.code_statut::text = ANY (ARRAY['EX'::text, 'EW'::text, 'CR'::text, 'EN'::text, 'VU'::text]))
        LEFT JOIN taxonomie.v_bdc_status sensreg ON sensreg.cd_ref = ref.cd_nom AND sensreg.cd_type_statut::text = 'SENSREG'::text
        GROUP BY  REF.cd_ref
        ) 
         SELECT row_number() over(order by s.area_name, s.regne, s.groupe_taxonomique) as bilan_id,
            s.area_name,
            s.regne,  
            s.groupe_taxonomique,
            count(DISTINCT s.id_synthese) AS nb_data,
            count(DISTINCT s.id_dataset)  AS nb_jdd,
            count(DISTINCT s.date_min::date) AS nb_jours_prospe, 
            count(DISTINCT s.cd_ref) AS nb_taxons_total,
            count(DISTINCT s.cd_ref)  FILTER ( WHERE  
                st.protection_stricte IS NOT NULL 
                OR st.patrimonial IS NOT NULL 
                OR st.menace_monde IS NOT NULL 
                OR st.menace_reg IS NOT NULL 
                OR st.sens_reg IS NOT NULL
            ) AS nb_taxons_a_statut,
            count(DISTINCT s.cd_ref)  FILTER ( WHERE  st.protection_stricte IS NOT NULL ) AS   nb_taxons_proteges,
            count(DISTINCT s.cd_ref)  FILTER ( WHERE  st.patrimonial IS NOT NULL ) AS   nb_taxons_znieff,
            count(DISTINCT s.cd_ref)  FILTER ( WHERE  st.menace_monde IS NOT NULL ) AS   nb_taxons_menaces_mond,
            count(DISTINCT s.cd_ref)  FILTER ( WHERE  st.menace_reg IS NOT NULL ) AS   nb_taxons_menaces_reg,
            count(DISTINCT s.cd_ref)  FILTER ( WHERE  st.sens_reg IS NOT NULL ) AS   nb_taxons_sensreg ,
            s.geom_grille_territoire
           FROM sdata s 
           JOIN ref_taxo_status st ON st.cd_ref = s.cd_ref
           GROUP BY s.regne, 
                s.groupe_taxonomique,
                s.area_name,
                s.geom_grille_territoire;

--ALTER TABLE gn_exports.v_bilan_taxo_maille10x10_plantae OWNER TO gnpag;
COMMENT ON VIEW gn_exports.v_bilan_taxo_maille10x10_plantae IS 'Statistiques par maille de 10km (total, protégé, etc). Détail selon groupe taxonomique (données validées, probables ou en attente de validation). Tous les jeux de données sont exploités (dont partenariaux).';
COMMENT ON COLUMN gn_exports.v_bilan_taxo_maille10x10_plantae.bilan_id IS 'Identifiant';
COMMENT ON COLUMN gn_exports.v_bilan_taxo_maille10x10_plantae.area_name IS 'Nom de la maille';
COMMENT ON COLUMN gn_exports.v_bilan_taxo_maille10x10_plantae.regne IS 'Regne';
COMMENT ON COLUMN gn_exports.v_bilan_taxo_maille10x10_plantae.groupe_taxonomique IS 'Groupe taxonomique (niveau group1_inpn)';
COMMENT ON COLUMN gn_exports.v_bilan_taxo_maille10x10_plantae.nb_data IS 'Nombre de données sur la maille pour le groupe taxonomique désigné';
COMMENT ON COLUMN gn_exports.v_bilan_taxo_maille10x10_plantae.nb_jdd IS 'Nombre de jeux de données sur la maille pour le groupe taxonomique désigné';
COMMENT ON COLUMN gn_exports.v_bilan_taxo_maille10x10_plantae.nb_jours_prospe IS 'Nombre de jours sur la maille pour le groupe taxonomique désigné';
COMMENT ON COLUMN gn_exports.v_bilan_taxo_maille10x10_plantae.nb_taxons_total IS 'Nombre de taxons (tous niveau confondus) sur la maille pour le groupe taxonomique désigné';
COMMENT ON COLUMN gn_exports.v_bilan_taxo_maille10x10_plantae.nb_taxons_a_statut IS 'Nombre de taxons ayant un statut de protection/menace/znieff/sensibilité (tous niveau confondus) sur la maille pour le groupe taxonomique désigné';
COMMENT ON COLUMN gn_exports.v_bilan_taxo_maille10x10_plantae.nb_taxons_proteges IS 'Nombre de taxons à protection stricte (tous niveau confondus) sur la maille pour le groupe taxonomique désigné';
COMMENT ON COLUMN gn_exports.v_bilan_taxo_maille10x10_plantae.nb_taxons_znieff IS 'Nombre de taxons déterminants ZNIEFF (tous niveau confondus) sur la maille pour le groupe taxonomique désigné';
COMMENT ON COLUMN gn_exports.v_bilan_taxo_maille10x10_plantae.nb_taxons_menaces_mond IS 'Nombre de taxons menacés mondialement (tous niveau confondus) sur la maille pour le groupe taxonomique désigné';
COMMENT ON COLUMN gn_exports.v_bilan_taxo_maille10x10_plantae.nb_taxons_menaces_reg IS 'Nombre de taxons menacés au niveau régional (tous niveau confondus) sur la maille pour le groupe taxonomique désigné';
COMMENT ON COLUMN gn_exports.v_bilan_taxo_maille10x10_plantae.nb_taxons_sensreg IS 'Nombre de taxons sensibles (tous niveau confondus) sur la maille pour le groupe taxonomique désigné';
COMMENT ON COLUMN gn_exports.v_bilan_taxo_maille10x10_plantae.geom_grille_territoire IS 'Geometrie';

  
------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------- View: gn_exports.v_bilan_taxo_maille10x10_fungi
-- DROP VIEW gn_exports.v_bilan_taxo_maille10x10_fungi;

CREATE OR REPLACE VIEW gn_exports.v_bilan_taxo_maille10x10_fungi AS
WITH   
    st_validation AS (      
        SELECT tn.id_nomenclature, tn.label_default, tn.mnemonique, tn.cd_nomenclature 
        FROM ref_nomenclatures.bib_nomenclatures_types bnt 
        JOIN ref_nomenclatures.t_nomenclatures tn 
        ON tn.id_type = bnt.id_type 
        WHERE bnt.mnemonique = 'STATUT_VALID' AND tn.cd_nomenclature IN ('1', '2', '6')
    ), sdata AS (
        -- Par défaut toutes les données de la synthèse valide
        --     En fonction des besoins rajouter des filtres
        SELECT 
            t.cd_ref, t.regne, 
            ref.group2_inpn as groupe_taxonomique,
            s.cd_nom, m.area_name, m.geom_grille_territoire, s.id_dataset, s.date_min, s.id_synthese
        FROM gn_synthese.synthese s
            JOIN taxonomie.taxref t ON s.cd_nom = t.cd_nom
        JOIN st_validation ON s.id_nomenclature_valid_status = st_validation.id_nomenclature
        JOIN gn_exports.mv_grilles_territoire m ON st_intersects(s.the_geom_local, m.geom_grille_territoire) AND  m.type_code = 'M10'   
        WHERE ref.regne::text = 'Fungi'::text
  ), ref_taxo_status AS (
          SELECT 
              REF.cd_ref,
            array_remove(array_agg(pat.cd_type_statut), NULL) AS patrimonial,
            array_remove(array_agg(pr.cd_type_statut), NULL)  AS protection_stricte,
            array_remove(array_agg(menacemond.cd_type_statut), NULL)  AS menace_monde,
            array_remove(array_agg(menacereg.cd_type_statut), NULL)  AS menace_reg,
            array_remove(array_agg(sensreg.cd_type_statut), NULL)  AS sens_reg
          FROM taxonomie.taxref ref
        LEFT JOIN taxonomie.v_bdc_status pat ON pat.cd_ref = ref.cd_ref AND pat.cd_type_statut::text = 'ZDET'::text
        LEFT JOIN taxonomie.v_bdc_status pr ON pr.cd_ref = ref.cd_nom AND (pr.code_statut::text = ANY (ARRAY['GUYM1'::text, 'GUYM3'::text, 'DV973'::text, 'GFAmRep2'::text, 'GFAmRep3'::text, 'GO2'::text, 'GO3'::text]))
        LEFT JOIN taxonomie.v_bdc_status menacemond ON menacemond.cd_ref = ref.cd_nom AND menacemond.cd_type_statut::text = 'LRM'::text AND (menacemond.code_statut::text = ANY (ARRAY['EX'::text, 'EW'::text, 'CR'::text, 'EN'::text, 'VU'::text]))
        LEFT JOIN taxonomie.v_bdc_status menacereg ON menacereg.cd_ref = ref.cd_nom AND menacereg.cd_type_statut::text = 'LRR'::text AND (menacereg.code_statut::text = ANY (ARRAY['EX'::text, 'EW'::text, 'CR'::text, 'EN'::text, 'VU'::text]))
        LEFT JOIN taxonomie.v_bdc_status sensreg ON sensreg.cd_ref = ref.cd_nom AND sensreg.cd_type_statut::text = 'SENSREG'::text
        GROUP BY  REF.cd_ref
        ) 
         SELECT row_number() over(order by s.area_name, s.regne, s.groupe_taxonomique) as bilan_id,
            s.area_name,
            s.regne,  
            s.groupe_taxonomique,
            count(DISTINCT s.id_synthese) AS nb_data,
            count(DISTINCT s.id_dataset)  AS nb_jdd,
            count(DISTINCT s.date_min::date) AS nb_jours_prospe, 
            count(DISTINCT s.cd_ref) AS nb_taxons_total,
            count(DISTINCT s.cd_ref)  FILTER ( WHERE  
                st.protection_stricte IS NOT NULL 
                OR st.patrimonial IS NOT NULL 
                OR st.menace_monde IS NOT NULL 
                OR st.menace_reg IS NOT NULL 
                OR st.sens_reg IS NOT NULL
            ) AS nb_taxons_a_statut,
            count(DISTINCT s.cd_ref)  FILTER ( WHERE  st.protection_stricte IS NOT NULL ) AS   nb_taxons_proteges,
            count(DISTINCT s.cd_ref)  FILTER ( WHERE  st.patrimonial IS NOT NULL ) AS   nb_taxons_znieff,
            count(DISTINCT s.cd_ref)  FILTER ( WHERE  st.menace_monde IS NOT NULL ) AS   nb_taxons_menaces_mond,
            count(DISTINCT s.cd_ref)  FILTER ( WHERE  st.menace_reg IS NOT NULL ) AS   nb_taxons_menaces_reg,
            count(DISTINCT s.cd_ref)  FILTER ( WHERE  st.sens_reg IS NOT NULL ) AS   nb_taxons_sensreg ,
            s.geom_grille_territoire
           FROM sdata s 
           JOIN ref_taxo_status st ON st.cd_ref = s.cd_ref
           GROUP BY s.regne, 
                s.groupe_taxonomique,
                s.area_name,
                s.geom_grille_territoire;


--ALTER TABLE gn_exports.v_bilan_taxo_maille10x10_fungi OWNER TO gnpag;
COMMENT ON VIEW gn_exports.v_bilan_taxo_maille10x10_fungi IS 'Statistiques par maille de 10km (total, protégé, etc). Détail selon groupe taxonomique (données validées, probables ou en attente de validation). Tous les jeux de données sont exploités (dont partenariaux).';
COMMENT ON COLUMN gn_exports.v_bilan_taxo_maille10x10_fungi.bilan_id IS 'Identifiant';
COMMENT ON COLUMN gn_exports.v_bilan_taxo_maille10x10_fungi.area_name IS 'Nom de la maille';
COMMENT ON COLUMN gn_exports.v_bilan_taxo_maille10x10_fungi.regne IS 'Regne';
COMMENT ON COLUMN gn_exports.v_bilan_taxo_maille10x10_fungi.groupe_taxonomique IS 'Groupe taxonomique (niveau group1_inpn)';
COMMENT ON COLUMN gn_exports.v_bilan_taxo_maille10x10_fungi.nb_data IS 'Nombre de données sur la maille pour le groupe taxonomique désigné';
COMMENT ON COLUMN gn_exports.v_bilan_taxo_maille10x10_fungi.nb_jdd IS 'Nombre de jeux de données sur la maille pour le groupe taxonomique désigné';
COMMENT ON COLUMN gn_exports.v_bilan_taxo_maille10x10_fungi.nb_jours_prospe IS 'Nombre de jours sur la maille pour le groupe taxonomique désigné';
COMMENT ON COLUMN gn_exports.v_bilan_taxo_maille10x10_fungi.nb_taxons_total IS 'Nombre de taxons (tous niveau confondus) sur la maille pour le groupe taxonomique désigné';
COMMENT ON COLUMN gn_exports.v_bilan_taxo_maille10x10_fungi.nb_taxons_a_statut IS 'Nombre de taxons ayant un statut de protection/menace/znieff/sensibilité (tous niveau confondus) sur la maille pour le groupe taxonomique désigné';
COMMENT ON COLUMN gn_exports.v_bilan_taxo_maille10x10_fungi.nb_taxons_proteges IS 'Nombre de taxons à protection stricte (tous niveau confondus) sur la maille pour le groupe taxonomique désigné';
COMMENT ON COLUMN gn_exports.v_bilan_taxo_maille10x10_fungi.nb_taxons_znieff IS 'Nombre de taxons déterminants ZNIEFF (tous niveau confondus) sur la maille pour le groupe taxonomique désigné';
COMMENT ON COLUMN gn_exports.v_bilan_taxo_maille10x10_fungi.nb_taxons_menaces_mond IS 'Nombre de taxons menacés mondialement (tous niveau confondus) sur la maille pour le groupe taxonomique désigné';
COMMENT ON COLUMN gn_exports.v_bilan_taxo_maille10x10_fungi.nb_taxons_menaces_reg IS 'Nombre de taxons menacés au niveau régional (tous niveau confondus) sur la maille pour le groupe taxonomique désigné';
COMMENT ON COLUMN gn_exports.v_bilan_taxo_maille10x10_fungi.nb_taxons_sensreg IS 'Nombre de taxons sensibles (tous niveau confondus) sur la maille pour le groupe taxonomique désigné';
COMMENT ON COLUMN gn_exports.v_bilan_taxo_maille10x10_fungi.geom_grille_territoire IS 'Geometrie';

