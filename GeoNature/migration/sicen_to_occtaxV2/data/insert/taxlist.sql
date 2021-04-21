-- mise à jour de la liste TH en fonction des données présentes dans la synthèse

INSERT INTO taxonomie.bib_noms (cd_nom, cd_ref, nom_francais)
WITH cd_nom_synthese AS (
	SELECT DISTINCT cd_nom FROM gn_synthese.synthese
)
SELECT s.cd_nom, t.cd_ref, COALESCE(t.nom_vern, t.lb_nom)
FROM cd_nom_synthese s
JOIN taxonomie.taxref t ON t.cd_nom = s.cd_nom 
LEFT JOIN taxonomie.bib_noms n ON n.cd_nom = s.cd_nom AND n.cd_ref = t.cd_ref
WHERE n.cd_nom IS NULL and n.cd_ref IS NULL
;

INSERT INTO taxonomie.cor_nom_liste (id_liste, id_nom)
SELECT l.id_liste, n.id_nom 
	FROM taxonomie.bib_noms n
	JOIN taxonomie.bib_listes l
	  ON l.nom_liste = 'Saisie Occtax'
	LEFT JOIN taxonomie.cor_nom_liste c
	  ON c.id_nom = n.id_nom
	WHERE c.id_nom IS NULL
;

-- MAJ de la vm

DROP MATERIALIZED VIEW IF EXISTS taxonomie.vm_taxref_list_forautocomplete;

CREATE MATERIALIZED VIEW taxonomie.vm_taxref_list_forautocomplete AS 
 SELECT row_number() OVER () AS gid,
    t.cd_nom,
    t.cd_ref,
    t.search_name,
    t.nom_valide,
    t.lb_nom,
    t.nom_vern,
    t.regne,
    t.group2_inpn
   FROM ( SELECT t_1.cd_nom,
            t_1.cd_ref,
            concat(t_1.lb_nom, ' =  <i> ', t_1.nom_valide, '</i>', ' - [', t_1.id_rang, ' - ', t_1.cd_nom, ']') AS search_name,
            t_1.nom_valide,
            t_1.lb_nom,
            t_1.nom_vern,
            t_1.regne,
            t_1.group2_inpn
           FROM taxonomie.taxref t_1
        UNION
         SELECT DISTINCT t_1.cd_nom,
            t_1.cd_ref,
            concat(split_part(t_1.nom_vern::text, ','::text, 1), ' =  <i> ', t_1.nom_valide, '</i>', ' - [', t_1.id_rang, ' - ', t_1.cd_ref, ']') AS search_name,
            t_1.nom_valide,
            t_1.lb_nom,
            t_1.nom_vern,
            t_1.regne,
            t_1.group2_inpn
           FROM taxonomie.taxref t_1
          WHERE t_1.nom_vern IS NOT NULL AND t_1.cd_nom = t_1.cd_ref) t
WITH DATA;

ALTER TABLE taxonomie.vm_taxref_list_forautocomplete
  OWNER TO joel;
COMMENT ON MATERIALIZED VIEW taxonomie.vm_taxref_list_forautocomplete
  IS 'Vue matérialisée permettant de faire des autocomplete construite à partir d''une requete sur tout taxref.';

-- Index: taxonomie.i_tri_vm_taxref_list_forautocomplete_search_name

-- DROP INDEX taxonomie.i_tri_vm_taxref_list_forautocomplete_search_name;

CREATE INDEX i_tri_vm_taxref_list_forautocomplete_search_name
  ON taxonomie.vm_taxref_list_forautocomplete
  USING gist
  (search_name COLLATE pg_catalog."default" gist_trgm_ops);

-- Index: taxonomie.i_vm_taxref_list_forautocomplete_cd_nom

-- DROP INDEX taxonomie.i_vm_taxref_list_forautocomplete_cd_nom;

CREATE INDEX i_vm_taxref_list_forautocomplete_cd_nom
  ON taxonomie.vm_taxref_list_forautocomplete
  USING btree
  (cd_nom);

-- Index: taxonomie.i_vm_taxref_list_forautocomplete_gid

-- DROP INDEX taxonomie.i_vm_taxref_list_forautocomplete_gid;

CREATE UNIQUE INDEX i_vm_taxref_list_forautocomplete_gid
  ON taxonomie.vm_taxref_list_forautocomplete
  USING btree
  (gid);

-- Index: taxonomie.i_vm_taxref_list_forautocomplete_search_name

-- DROP INDEX taxonomie.i_vm_taxref_list_forautocomplete_search_name;

CREATE INDEX i_vm_taxref_list_forautocomplete_search_name
  ON taxonomie.vm_taxref_list_forautocomplete
  USING btree
  (search_name COLLATE pg_catalog."default");

