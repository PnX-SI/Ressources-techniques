Ci dessous des exemples de requêtes pouvant être combinées qui nous servent à faire des exports.

Ces vues sont propres au contexte Parc national des Cévennes : attribut de taxhub, filtre sur la région occitanie, référentiel geographique, ...


## Vue permettant d'avoir l'espèce des taxons infraspécifiques

Vue matérialisée permettant de récupérer l'espece et le genre d'un taxon de rang inférieur ou égale à l'espèce

```sql

CREATE MATERIALIZED VIEW taxonomie.vm_taxref_taxon_to_especes AS
 WITH
 RECURSIVE tax_hier AS (
         SELECT t.cd_nom,
            t.cd_ref,
            t.nom_complet,
            t.cd_sup,
            t.id_rang,
            t.cd_nom AS initial_cd_nom,
            t.cd_ref AS initial_cd_ref,
            t.nom_valide AS initial_nom_valide
           FROM taxonomie.taxref t
        UNION ALL
         SELECT tx2.cd_nom,
            tx2.cd_ref,
            tx2.nom_complet,
            tx2.cd_sup,
            tx2.id_rang,
            p.initial_cd_nom,
            p.initial_cd_ref,
            p.initial_nom_valide
           FROM tax_hier p
             JOIN taxonomie.taxref tx2 ON tx2.cd_nom = p.cd_sup
        )
 SELECT e.initial_cd_nom,
    e.initial_cd_ref,
    e.initial_nom_valide,
    e.sp_cd_nom,
    e.sp_cd_ref,
    e.sp_nom_complet,
    g.gn_cd_nom,
    g.gn_cd_ref,
    g.gn_nom_complet
   FROM ( SELECT DISTINCT e_1.cd_nom AS sp_cd_nom,
            e_1.cd_ref as sp_cd_ref,
            e_1.nom_complet AS sp_nom_complet,
            e_1.initial_cd_nom,
            e_1.initial_cd_ref,
            e_1.initial_nom_valide
           FROM tax_hier e_1
          WHERE e_1.id_rang::text = 'ES'::text) e
     JOIN ( SELECT DISTINCT g_1.cd_nom AS gn_cd_nom,
            g_1.cd_ref as gn_cd_ref,
            g_1.nom_complet AS gn_nom_complet,
            g_1.initial_cd_nom
           FROM tax_hier g_1
          WHERE g_1.id_rang::text = 'GN'::text) g ON e.initial_cd_nom = g.initial_cd_nom;
COMMENT ON MATERIALIZED VIEW taxonomie.vm_taxref_taxon_to_especes IS 'Vue matérialisée permettant de récupérer l''espece ou le genre d''un taxon de rang inférieur ou égale à l''espèce';

```

## Synthèse de la BDC_statut

Vue de synthetisant les informations de la BDC statut par taxon : déterminante znieff (Occitanie), à une protection national, régionale, statut uicn

```sql
CREATE MATERIALIZED VIEW taxonomie.v_taxref_bdc_statut_summary AS
WITH  znieff AS (
         SELECT bst.cd_ref,
            'x'::text AS st_znieff,
            bst.rq_statut
           FROM taxonomie.bdc_statut_cor_text_values c
             JOIN taxonomie.bdc_statut_text t_1 ON c.id_text = t_1.id_text AND t_1.cd_type_statut::text = 'ZDET'::text AND t_1.cd_sig::text = 'INSEER91'::text
             JOIN taxonomie.bdc_statut_values v ON v.id_value = c.id_value
             JOIN taxonomie.bdc_statut_taxons bst ON bst.id_value_text = c.id_value_text
        ), hier AS (
         SELECT 1 AS o,
            'LRR'::text AS st
        UNION
         SELECT 2 AS o,
            'LRN'::text AS st
        UNION
         SELECT 3 AS o,
            'LRE'::text AS st
        ), st_uicn AS (
         SELECT DISTINCT ON (tax.cd_ref) t_1.cd_type_statut,
            v.code_statut,
            concat(v.code_statut, ' (', hier.st, ')') AS st_uicn,
            tax.cd_ref,
            hier.o,
            hier.st
           FROM taxonomie.bdc_statut_text t_1
             JOIN taxonomie.bdc_statut_type bst ON t_1.cd_type_statut::text = bst.cd_type_statut::text
             JOIN taxonomie.bdc_statut_cor_text_values c ON c.id_text = t_1.id_text
             JOIN taxonomie.bdc_statut_values v ON c.id_value = v.id_value
             JOIN taxonomie.bdc_statut_taxons tax ON tax.id_value_text = c.id_value_text
             JOIN hier ON t_1.cd_type_statut::text = hier.st
          WHERE t_1.enable = true AND bst.regroupement_type::text = 'Liste rouge'::text 
            AND NOT COALESCE(t_1.cd_st_text, ''::character varying)::text = 'UICN_FR_OIS_HIV'::text 
            AND (v.code_statut::text = ANY (ARRAY['VU', 'EN', 'CR', 'CR*']::text[])
          )
          ORDER BY tax.cd_ref, hier.o
        )
 SELECT DISTINCT ref.nom_valide,
    ref.cd_ref,
    ref.nom_vern,
    ref.group1_inpn,
    ref.group2_inpn,
    ref.regne,
    ref.phylum,
    ref.classe,
    ref.ordre,
    ref.famille,
    ref.id_rang,
    znieff.st_znieff,
    st_dir_eur.value AS st_dir_europeenne,
    st_pn.value AS st_prot_national,
    st_pr.value AS st_prot_regional,
    st_uicn.st_uicn AS st_uicn_max
    FROM taxonomie.taxref t
     JOIN taxonomie.taxref ref ON t.cd_ref = ref.cd_nom
     LEFT JOIN znieff ON t.cd_ref = znieff.cd_ref
     LEFT JOIN st_uicn ON t.cd_ref = st_uicn.cd_ref
     LEFT JOIN LATERAL ( SELECT vbs.cd_ref,
            vbs.code_statut,
            'x'::text AS value
           FROM taxonomie.v_bdc_status vbs
          WHERE (vbs.code_statut::text = ANY (ARRAY['CDH2'::character varying, 'CDO1'::character varying]::text[])) AND vbs.cd_ref = t.cd_ref) st_dir_eur ON true
     LEFT JOIN LATERAL ( SELECT vbs.cd_ref,
            vbs.code_statut,
            'x'::text AS value
           FROM taxonomie.v_bdc_status vbs
          WHERE vbs.cd_type_statut::text = 'PN'::text AND vbs.cd_ref = t.cd_ref) st_pn ON true
     LEFT JOIN LATERAL ( SELECT vbs.cd_ref,
            vbs.code_statut,
            'x'::text AS value
           FROM taxonomie.v_bdc_status vbs
          WHERE vbs.cd_type_statut::text = 'PR'::text AND vbs.cd_ref = t.cd_ref AND vbs.cd_sig::text = 'INSEER91'::text) st_pr ON true;

COMMENT ON MATERIALIZED VIEW taxonomie.v_taxref_bdc_statut_summary IS 'Vue matérialisée synthetisant les informations de la BDC statut par taxon : est déterminante znieff (Occitanie), à une protection national, régionale, statut uicn';
```


## Répartition geographique des données de synthèse

Résumé par taxon des informations de la synthèse (1ère, denière obs, nb de données par zones biogeographiqes, ...).

```sql
 SELECT
    t_1.cd_ref,
    min(s.date_min) AS min_date,
    max(s.date_max) AS max_date,
    count(DISTINCT s.id_synthese) AS nb_total,
    min(s.altitude_min) AS altitude_min,
    max(s.altitude_max) AS altitude_max,
    count(DISTINCT a.id_area) filter (where at.type_code='M1') AS nb_mailles,
    count(*) filter (where l.id_area = 1) AS    zc,
    count(*) filter (where l.id_area = 28) AS   aa,
    count(*) filter (where l.id_area = 37) AS   pec,
    count(*) filter (where l.id_area = 18379) AS    zb_cg,
    count(*) filter (where l.id_area = 18380) AS    zb_ml,
    count(*) filter (where l.id_area = 18381) AS    zb_ce,
    count(*) filter (where l.id_area = 18382) AS    zb_pc,
    count(*) filter (where l.id_area = 18383) AS    zb_ai
FROM gn_synthese.synthese s
JOIN taxonomie.taxref t_1 ON t_1.cd_nom = s.cd_nom
JOIN gn_synthese.cor_area_synthese a ON s.id_synthese = a.id_synthese
JOIN ref_geo.l_areas l ON l.id_area = a.id_area
JOIN ref_geo.bib_areas_types at ON at.id_type = l.id_type AND at.type_code IN ('ZC', 'AA', 'PEC', 'ZB', 'M1')
WHERE NOT s.id_nomenclature_valid_status = 321
GROUP BY t_1.cd_ref;
```

```sql
-- Limité au niveau espèce
CREATE OR REPLACE VIEW gn_synthese.v_pivot_espece_repartition_zb
AS
SELECT
    t_1.sp_cd_ref AS sp_cd_ref,
    count(DISTINCT t_1.initial_cd_ref) AS nb_taxon_aggrege,
    string_agg(DISTINCT t_1.initial_nom_valide, ', ') AS  taxon_aggrege,
    min(s.date_min) AS min_date,
    max(s.date_max) AS max_date,
    count(DISTINCT s.id_synthese) AS nb_total,
    min(s.altitude_min) AS altitude_min,
    max(s.altitude_max) AS altitude_max,
    count(DISTINCT a.id_area) filter (where at.type_code='M1') AS nb_mailles,
    count(*) filter (where l.id_area = 1) AS    zc,
    count(*) filter (where l.id_area = 28) AS   aa,
    count(*) filter (where l.id_area = 37) AS   pec,
    count(*) filter (where l.id_area = 18379) AS    zb_cg,
    count(*) filter (where l.id_area = 18380) AS    zb_ml,
    count(*) filter (where l.id_area = 18381) AS    zb_ce,
    count(*) filter (where l.id_area = 18382) AS    zb_pc,
    count(*) filter (where l.id_area = 18383) AS    zb_ai
FROM gn_synthese.synthese s
JOIN taxonomie.vm_taxref_taxon_to_especes t_1 ON t_1.initial_cd_nom = s.cd_nom
JOIN gn_synthese.cor_area_synthese a ON s.id_synthese = a.id_synthese
JOIN ref_geo.l_areas l ON l.id_area = a.id_area
JOIN ref_geo.bib_areas_types at ON at.id_type = l.id_type AND at.type_code IN ('ZC', 'AA', 'PEC', 'ZB', 'M1')
WHERE NOT s.id_nomenclature_valid_status = 321
GROUP BY t_1.sp_cd_ref;
```

## Attributs des taxons

```sql
CREATE OR REPLACE VIEW gn_synthese.v_synthese_taxon_for_export_view
AS WITH taxon_att AS (
         SELECT a_1.cd_ref,
            json_object_agg(b.nom_attribut, a_1.valeur_attribut) AS attrib
           FROM taxonomie.cor_taxon_attribut a_1
             JOIN taxonomie.bib_attributs b ON a_1.id_attribut = b.id_attribut
          WHERE (b.nom_attribut::text = ANY (ARRAY['patrimonial', 'marcoeur_33', 'enjeux_occitanie', 'eee_occitanie', 'enjeux_niveau_pnc',
             'atlas_milieu', 'commentaire_habitat']::text[])) AND NOT a_1.valeur_attribut = 'non'::text
          GROUP BY a_1.cd_ref
        ), sp_douteuse AS (
         SELECT DISTINCT bn.cd_ref,
            'x'::text AS value
           FROM taxonomie.bib_listes bl
             JOIN taxonomie.cor_nom_liste cnl ON bl.id_liste = cnl.id_liste
             JOIN taxonomie.bib_noms bn ON bn.id_nom = cnl.id_nom
          WHERE bl.code_liste::text = '1000000'::text
        )
 SELECT DISTINCT ref.nom_valide,
    ref.cd_ref,
    ref.nom_vern,
    ref.group1_inpn,
    ref.group2_inpn,
    ref.regne,
    ref.phylum,
    ref.classe,
    ref.ordre,
    ref.famille,
    ref.id_rang,
    att.attrib ->> 'patrimonial'::text AS patrimonial,
    att.attrib ->> 'enjeux_occitanie'::text AS enjeux_occitanie,
    att.attrib ->> 'enjeux_niveau_pnc'::text AS enjeux_niveau_pnc,
    att.attrib ->> 'marcoeur_33'::text AS marcoeur_33,
    att.attrib ->> 'eee_occitanie'::text AS eee_occitanie,
    att.attrib ->> 'atlas_milieu'::text AS milieu,
    att.attrib ->> 'commentaire_habitat'::text AS commentaire_habitat,
    ref.st_znieff,
    ref.st_dir_europeenne AS st_dir_europeenne,
    ref.st_prot_national AS st_prot_national,
    ref.st_prot_regional AS st_prot_regional,
    ref.st_uicn_max AS st_uicn_max,
    sp_douteuse.value AS sp_douteuse,
        CASE
            WHEN ref.st_prot_regional = 'x'::text
                OR ref.st_prot_national = 'x'::text
                OR ref.st_dir_europeenne = 'x'::text
                OR NOT (att.attrib ->> 'marcoeur_33'::text) IS NULL
                OR NOT (att.attrib ->> 'patrimonial'::text) IS NULL
            THEN 'x'::text
            ELSE NULL::text
        END AS enjeu_abc
   FROM gn_synthese.synthese s
    JOIN taxonomie.taxref t ON s.cd_nom = t.cd_nom
    JOIN taxonomie.v_taxref_bdc_statut_summary ref ON t.cd_ref = ref.cd_ref
    LEFT JOIN taxon_att att ON t.cd_ref = att.cd_ref
    LEFT JOIN sp_douteuse ON t.cd_ref = sp_douteuse.cd_ref;
  ```
