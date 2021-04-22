--IMPORT FOREIGN SCHEMA taxonomie FROM SERVER geonature1server INTO v1_compat;
-- que faire des taxons
-- 441839;"Évêque bleu-noir ";"Cyanocompsa cyanoides"
-- 765714;"";"Combretum laxum"

-- donnés par la commande:
--
-- select DISTINCT t1.cd_nom FROM v1_compat.syntheseff s
-- join v1_compat.taxref t1
-- ON t1.cd_nom = s.cd_nom
-- LEFT JOIN taxonomie.taxref t
-- ON t.cd_nom =t1.cd_nom
-- WHERE t.cd_nom IS NULL
-- ORDER BY cd_nom;



-- ajout des taxon exotiques  >= 99000000

INSERT INTO taxonomie.taxref(
             cd_nom, id_statut, id_habitat, id_rang, regne, phylum, classe, 
             ordre, famille, sous_famille, tribu, cd_taxsup, cd_sup, cd_ref, 
             lb_nom, lb_auteur, nom_complet, nom_complet_html, nom_valide, 
             nom_vern, nom_vern_eng, group1_inpn, group2_inpn, url)
select       
	cd_nom, id_statut, id_habitat, id_rang, regne, phylum, classe, 
        ordre, famille, sous_famille, tribu, cd_taxsup, cd_sup, cd_ref, 
	lb_nom, lb_auteur, nom_complet, nom_complet_html, nom_valide, 
	nom_vern, nom_vern_eng, group1_inpn, group2_inpn, url

	from v1_compat.taxref
	where cd_nom >= 99900000
;


-- bib nom

INSERT INTO taxonomie.bib_noms(
            id_nom, cd_nom, cd_ref, nom_francais, comments)
SELECT vn.id_nom, vn.cd_nom, vn.cd_ref, nom_francais, comments
        FROM v1_compat.bib_noms vn
JOIN taxonomie.taxref t on t.cd_ref = vn.cd_ref and t.cd_nom = vn.cd_nom and t.cd_nom = t.cd_ref
WHERE vn.cd_nom NOT in (441849, 765714)
;


-- liste nom

INSERT INTO taxonomie.bib_listes(
            id_liste, nom_liste, code_liste, desc_liste, picto, regne, group2_inpn)
SELECT 
            id_liste, nom_liste, id_liste, desc_liste, picto, regne, group2_inpn
        FROM v1_compat.bib_listes
;


-- cor nom liste

INSERT INTO taxonomie.cor_nom_liste(
            id_liste, id_nom)
SELECT 
            id_liste, vc.id_nom
            FROM v1_compat.cor_nom_liste vc
            JOIN taxonomie.bib_noms bn 
                ON bn.id_nom = vc.id_nom
; 

