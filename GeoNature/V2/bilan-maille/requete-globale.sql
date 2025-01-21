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
---------------------> Dispo ci-après: déclinaisons pour stats globales, animalia, plantae et fungi
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
                st.protection_stricte <> '{}' 
                OR st.patrimonial <> '{}' 
                OR st.menace_monde <> '{}' 
                OR st.menace_reg <> '{}' 
                OR st.sens_reg <> '{}'
            ) AS nb_taxons_a_statut,
            count(DISTINCT s.cd_ref)  FILTER ( WHERE  st.protection_stricte <> '{}' ) AS   nb_taxons_proteges,
            count(DISTINCT s.cd_ref)  FILTER ( WHERE  st.patrimonial <> '{}' ) AS   nb_taxons_znieff,
            count(DISTINCT s.cd_ref)  FILTER ( WHERE  st.menace_monde <> '{}' ) AS   nb_taxons_menaces_mond,
            count(DISTINCT s.cd_ref)  FILTER ( WHERE  st.menace_reg <> '{}' ) AS   nb_taxons_menaces_reg,
            count(DISTINCT s.cd_ref)  FILTER ( WHERE  st.sens_reg <> '{}' ) AS   nb_taxons_sensreg ,
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
    ), sdata AS (
        -- Par défaut toutes les données de la synthèse valide
        --     En fonction des besoins rajouter des filtres
        SELECT t.cd_ref, 'Tous regnes'::text AS regne, 'Tous groupes confondus'::text AS groupe_taxonomique, s.cd_nom, m.area_name, m.geom_grille_territoire, s.id_dataset, s.date_min, s.id_synthese
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
                st.protection_stricte <> '{}' 
                OR st.patrimonial <> '{}' 
                OR st.menace_monde <> '{}' 
                OR st.menace_reg <> '{}' 
                OR st.sens_reg <> '{}'
            ) AS nb_taxons_a_statut,
            count(DISTINCT s.cd_ref)  FILTER ( WHERE  st.protection_stricte <> '{}' ) AS   nb_taxons_proteges,
            count(DISTINCT s.cd_ref)  FILTER ( WHERE  st.patrimonial <> '{}' ) AS   nb_taxons_znieff,
            count(DISTINCT s.cd_ref)  FILTER ( WHERE  st.menace_monde <> '{}' ) AS   nb_taxons_menaces_mond,
            count(DISTINCT s.cd_ref)  FILTER ( WHERE  st.menace_reg <> '{}' ) AS   nb_taxons_menaces_reg,
            count(DISTINCT s.cd_ref)  FILTER ( WHERE  st.sens_reg <> '{}' ) AS   nb_taxons_sensreg ,
            s.geom_grille_territoire
           FROM sdata s 
           JOIN ref_taxo_status st ON st.cd_ref = s.cd_ref
           GROUP BY s.regne, 
                s.groupe_taxonomique,
                s.area_name,
                s.geom_grille_territoire;

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
                st.protection_stricte <> '{}' 
                OR st.patrimonial <> '{}' 
                OR st.menace_monde <> '{}' 
                OR st.menace_reg <> '{}' 
                OR st.sens_reg <> '{}'
            ) AS nb_taxons_a_statut,
            count(DISTINCT s.cd_ref)  FILTER ( WHERE  st.protection_stricte <> '{}' ) AS   nb_taxons_proteges,
            count(DISTINCT s.cd_ref)  FILTER ( WHERE  st.patrimonial <> '{}' ) AS   nb_taxons_znieff,
            count(DISTINCT s.cd_ref)  FILTER ( WHERE  st.menace_monde <> '{}' ) AS   nb_taxons_menaces_mond,
            count(DISTINCT s.cd_ref)  FILTER ( WHERE  st.menace_reg <> '{}' ) AS   nb_taxons_menaces_reg,
            count(DISTINCT s.cd_ref)  FILTER ( WHERE  st.sens_reg <> '{}' ) AS   nb_taxons_sensreg ,
            s.geom_grille_territoire
           FROM sdata s 
           JOIN ref_taxo_status st ON st.cd_ref = s.cd_ref
           GROUP BY s.regne, 
                s.groupe_taxonomique,
                s.area_name,
                s.geom_grille_territoire;


--ALTER TABLE gn_exports.v_bilan_taxo_maille10x10_animalia OWNER TO gnpag;
COMMENT ON VIEW gn_exports.v_bilan_taxo_maille10x10_animalia IS 'Statistiques des connaissances sur la faune par maille de 10km (total, protégé, etc). Détail selon groupe taxonomique (données validées, probables ou en attente de validation). Tous les jeux de données sont exploités (dont partenariaux).';
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
            ref.group1_inpn as groupe_taxonomique,
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
                st.protection_stricte <> '{}' 
                OR st.patrimonial <> '{}' 
                OR st.menace_monde <> '{}' 
                OR st.menace_reg <> '{}' 
                OR st.sens_reg <> '{}'
            ) AS nb_taxons_a_statut,
            count(DISTINCT s.cd_ref)  FILTER ( WHERE  st.protection_stricte <> '{}' ) AS   nb_taxons_proteges,
            count(DISTINCT s.cd_ref)  FILTER ( WHERE  st.patrimonial <> '{}' ) AS   nb_taxons_znieff,
            count(DISTINCT s.cd_ref)  FILTER ( WHERE  st.menace_monde <> '{}' ) AS   nb_taxons_menaces_mond,
            count(DISTINCT s.cd_ref)  FILTER ( WHERE  st.menace_reg <> '{}' ) AS   nb_taxons_menaces_reg,
            count(DISTINCT s.cd_ref)  FILTER ( WHERE  st.sens_reg <> '{}' ) AS   nb_taxons_sensreg ,
            s.geom_grille_territoire
           FROM sdata s 
           JOIN ref_taxo_status st ON st.cd_ref = s.cd_ref
           GROUP BY s.regne, 
                s.groupe_taxonomique,
                s.area_name,
                s.geom_grille_territoire;

--ALTER TABLE gn_exports.v_bilan_taxo_maille10x10_plantae OWNER TO gnpag;
COMMENT ON VIEW gn_exports.v_bilan_taxo_maille10x10_plantae IS 'Statistiques des connaissances sur la flore par maille de 10km (total, protégé, etc). Détail selon groupe taxonomique (données validées, probables ou en attente de validation). Tous les jeux de données sont exploités (dont partenariaux).';
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
            t.group1_inpn as groupe_taxonomique,
            s.cd_nom, m.area_name, m.geom_grille_territoire, s.id_dataset, s.date_min, s.id_synthese
        FROM gn_synthese.synthese s
            JOIN taxonomie.taxref t ON s.cd_nom = t.cd_nom
        JOIN st_validation ON s.id_nomenclature_valid_status = st_validation.id_nomenclature
        JOIN gn_exports.mv_grilles_territoire m ON st_intersects(s.the_geom_local, m.geom_grille_territoire) AND  m.type_code = 'M10'   
        WHERE t.regne::text = 'Fungi'::text
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
                st.protection_stricte <> '{}' 
                OR st.patrimonial <> '{}' 
                OR st.menace_monde <> '{}' 
                OR st.menace_reg <> '{}' 
                OR st.sens_reg <> '{}'
            ) AS nb_taxons_a_statut,
            count(DISTINCT s.cd_ref)  FILTER ( WHERE  st.protection_stricte <> '{}' ) AS   nb_taxons_proteges,
            count(DISTINCT s.cd_ref)  FILTER ( WHERE  st.patrimonial <> '{}' ) AS   nb_taxons_znieff,
            count(DISTINCT s.cd_ref)  FILTER ( WHERE  st.menace_monde <> '{}' ) AS   nb_taxons_menaces_mond,
            count(DISTINCT s.cd_ref)  FILTER ( WHERE  st.menace_reg <> '{}' ) AS   nb_taxons_menaces_reg,
            count(DISTINCT s.cd_ref)  FILTER ( WHERE  st.sens_reg <> '{}' ) AS   nb_taxons_sensreg ,
            s.geom_grille_territoire
           FROM sdata s 
           JOIN ref_taxo_status st ON st.cd_ref = s.cd_ref
           GROUP BY s.regne, 
                s.groupe_taxonomique,
                s.area_name,
                s.geom_grille_territoire;


--ALTER TABLE gn_exports.v_bilan_taxo_maille10x10_fungi OWNER TO gnpag;
COMMENT ON VIEW gn_exports.v_bilan_taxo_maille10x10_fungi IS 'Statistiques des connaissances sur la fonge par maille de 10km (total, protégé, etc). Détail selon groupe taxonomique (données validées, probables ou en attente de validation). Tous les jeux de données sont exploités (dont partenariaux).';
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

