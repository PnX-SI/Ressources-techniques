--IMPORT FOREIGN SCHEMA taxonomie FROM SERVER geonature1server INTO v1_compat;
-- que faire des taxons
-- 441839;Évêque bleu-noir ;Cyanocompsa cyanoides
-- 765714;;Combretum laxum

-- donnés par la commande:
--
-- select DISTINCT t1.cd_nom FROM v1_compat.syntheseff s
-- join v1_compat.taxref t1
-- ON t1.cd_nom = s.cd_nom
-- LEFT JOIN taxonomie.taxref t
-- ON t.cd_nom =t1.cd_nom
-- WHERE t.cd_nom IS NULL
-- ORDER BY cd_nom;

----------------- Le référentiel est taxref v14!
UPDATE gn_commons.t_parameters 	SET parameter_value = 'Taxref V14.0' WHERE id_parameter = 1;


----------------- Ajout des taxon exotiques  >= 99000000
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
	where cd_nom >= 99900000;
;

------------ Import de Bib_nom sur la base de l'existant (GN1.9)
INSERT INTO taxonomie.bib_noms(
            id_nom, cd_nom, cd_ref, nom_francais, comments)
SELECT vn.id_nom, vn.cd_nom, vn.cd_ref, nom_francais, comments
        FROM v1_compat.bib_noms vn
JOIN taxonomie.taxref t on t.cd_ref = vn.cd_ref and t.cd_nom = vn.cd_nom and t.cd_nom = t.cd_ref
WHERE vn.cd_nom NOT in (441849, 765714)
;

------------- Compéments dans bib_noms avec Taxref v14 où statut_GF <> A et pas en lien avec le milieu marin.
COPY taxonomie.import_taxref FROM  '/tmp/taxhub/TAXREF_v14_2020/TAXREFv14.txt' WITH  CSV HEADER DELIMITER E'\t'  encoding 'UTF-8'; 
-- Compléments dans bib_noms sur la base de taxref
SELECT setval('taxonomie.bib_noms_id_nom_seq', (SELECT MAX(id_nom) FROM taxonomie.bib_noms)+1);
INSERT INTO taxonomie.bib_noms(	cd_nom, cd_ref, nom_francais)
	SELECT cd_nom, cd_ref, nom_vern
		FROM taxonomie.import_taxref
		WHERE gf <> 'A' 
			AND habitat in ('2','3', '7', '8')
			AND cd_ref not in (select cd_ref from taxonomie.bib_noms);
---- update des bib_noms (refs et noms vernaculaires !
UPDATE taxonomie.bib_noms
	SET cd_ref = taxref.cd_ref
	FROM taxonomie.taxref
	WHERE bib_noms.cd_nom = taxref.cd_nom; -- les cd_ref
UPDATE taxonomie.bib_noms
	SET nom_francais = nom_vern
	FROM (select import_taxref.cd_nom, import_taxref.cd_ref, habitat, nom_vern
				FROM taxonomie.import_taxref
				WHERE gf <> 'A' 
				and nom_vern is not null 
				and habitat in ('2','3', '7', '8')) as liste_sp_gf
	WHERE bib_noms.cd_nom = liste_sp_gf.cd_nom and nom_francais <> nom_vern; -- les noms_vernaculaires


-------------------------- liste nom + celle d'occtax
INSERT INTO taxonomie.bib_listes(
            id_liste, nom_liste, code_liste, desc_liste, picto, regne, group2_inpn)
SELECT id_liste, nom_liste, id_liste, desc_liste, picto, regne, group2_inpn
        FROM v1_compat.bib_listes ;
-- Ajout de la liste OccTax
INSERT INTO taxonomie.bib_listes(	id_liste, code_liste, nom_liste, desc_liste, picto, regne, group2_inpn)
	VALUES (100,'OCCTAX','Saisie Occtax','Liste des noms dont la saisie est proposée dans le module Occtax','images/pictos/nopicto.gif','','');



-- cor nom liste
INSERT INTO taxonomie.cor_nom_liste(id_liste, id_nom)
    SELECT 1, id_nom   --Amphibiens
        FROM taxonomie.bib_noms  
        WHERE cd_nom in (select cd_nom from taxonomie.taxref WHERE classe ='Amphibia')
    UNION SELECT 16, id_nom   --Arachnides
        FROM taxonomie.bib_noms  
        WHERE cd_nom in (select cd_nom from taxonomie.taxref WHERE classe ='Arachnida')
    UNION SELECT 12, id_nom   --Oiseaux
        FROM taxonomie.bib_noms  
        WHERE cd_nom in (select cd_nom from taxonomie.taxref WHERE classe ='Aves')
    UNION SELECT 10, id_nom   --Bivalves
        FROM taxonomie.bib_noms  
        WHERE cd_nom in (select cd_nom from taxonomie.taxref WHERE classe ='Bivalvia')
    UNION SELECT 8, id_nom   --Gastéropodes
        FROM taxonomie.bib_noms  
        WHERE cd_nom in (select cd_nom from taxonomie.taxref WHERE classe ='Gastropoda')
    UNION SELECT 9, id_nom   --Insectes
        FROM taxonomie.bib_noms  
        WHERE cd_nom in (select cd_nom from taxonomie.taxref WHERE classe ='Insecta')
    UNION SELECT 11, id_nom   --Mammifères
        FROM taxonomie.bib_noms  
        WHERE cd_nom in (select cd_nom from taxonomie.taxref WHERE classe ='Mammalia')
    UNION SELECT 14, id_nom   --Reptiles
        FROM taxonomie.bib_noms  
        WHERE cd_nom in (select cd_nom from taxonomie.taxref WHERE classe ='Reptilia')
    UNION SELECT 13, id_nom   --Poissons
        FROM taxonomie.bib_noms  
        WHERE cd_nom in (select cd_nom from taxonomie.taxref WHERE classe in ('Actinoperygii', 'Actinopterygii', 'Dipneusti'))
    UNION SELECT 15, id_nom   --Myriapodes
        FROM taxonomie.bib_noms  
        WHERE cd_nom in (select cd_nom from taxonomie.taxref WHERE classe in ('Chilopoda', 'Diplopoda', 'Pauropoda', 'Symphyla'))
    UNION SELECT 5, id_nom   --Crustacés
        FROM taxonomie.bib_noms  
        WHERE cd_nom in (select cd_nom from taxonomie.taxref WHERE classe in ('Malacostraca', 'Hexanauplia', 'Copepoda'))
    UNION SELECT 306, id_nom   --Monocotylédones
        FROM taxonomie.bib_noms  
        WHERE cd_nom in (select cd_nom from taxonomie.taxref WHERE ordre in ('Alismatales', 'Asparagales', 'Arecales', 'Commelinales', 'Poales', 'Zingiberales', 'Dioscoreales', 'Liliales', 'Pandanales'))
    UNION SELECT 305, id_nom   --Ptéridophytes
        FROM taxonomie.bib_noms  
        WHERE cd_nom in (select cd_nom from taxonomie.taxref WHERE ordre in ('Isoetales', 'Lycopodiales', 'Selaginellales', 'Equisetales', 'Marattiales', 'Ophioglossales', 'Psilotales', 'Cyatheales', 'Gleicheniales', 'Hymenophyllales', 'Osmundales', 'Polypodiales', 'Salviniales', 'Schizaeales'))
    UNION SELECT 307, id_nom   --Dicotylédones
        FROM taxonomie.bib_noms  
        WHERE cd_nom in (select cd_nom from taxonomie.taxref WHERE ordre in ('Amborellales', 'Apiales', 'Aquifoliales', 'Asterales', 'Boraginales', 'Cornales', 'Dipsacales', 'Ericales', 'Escalloniales', 'Garryales', 'Gentianales', 'Icacinales', 'Lamiales', 'Metteniusales', 'Paracryphiales', 'Solanales', 'Austrobaileyales', 'Chloranthales', 'Buxales', 'Caryophyllales', 'Ceratophyllales', 'Dilleniales', 'Acorales', 'Alismatales', 'Asparagales', 'Clade', 'Dioscoreales', 'Liliales', 'Pandanales', 'Canellales', 'Laurales', 'Magnoliales', 'Piperales', 'Gunnerales', 'Nymphaeales', 'Proteales', 'Ranunculales', 'Brassicales', 'Celastrales', 'Crossosomatales', 'Cucurbitales', 'Fabales', 'Fagales', 'Geraniales', 'Malpighiales', 'Malvales', 'Myrtales', 'Oxalidales', 'Picramniales', 'Rosales', 'Sapindales', 'Vitales', 'Zygophyllales', 'Santalales', 'Saxifragales'))
    UNION SELECT 301, id_nom   --Bryophytes
        FROM taxonomie.bib_noms  
        WHERE cd_nom in (select cd_nom from taxonomie.taxref WHERE ordre in ('Anthocerotales', 'Dendrocerotales', 'Leiosporocerotales', 'Notothyladales', 'Phymatocerales', 'Andreaeales', 'Aulacomniales', 'Bartramiales', 'Bryales', 'Buxbaumiales', 'Catoscopiales', 'Dicranales', 'Diphysciales', 'Encalyptales', 'Funariales', 'Gigaspermales', 'Grimmiales', 'Hedwigiales', 'Hookeriales', 'Hypnales', 'Hypnodendrales', 'Orthotrichales', 'Polytrichales', 'Pottiales', 'Ptychomniales', 'Rhizogoniales', 'Sphagnales', 'Splachnales', 'Tetraphidales', 'Timmiales', 'Blasiales', 'Calobryales', 'Fossombroniales', 'Jungermanniales', 'Lunulariales', 'Marchantiales', 'Metzgeriales', 'Pallaviciniales', 'Pelliales', 'Pleuroziales', 'Porellales', 'Ptilidiales', 'Sphaerocarpales', 'Treubiales'))
    UNION SELECT 308, id_nom   --Gymnospermes
        FROM taxonomie.bib_noms  
        WHERE cd_nom in (select cd_nom from taxonomie.taxref WHERE ordre in ('Ginkgoales', 'Ephedrales', 'Gnetales', 'Araucariales', 'Cupressales', 'Pinales'))
    UNION SELECT 2, id_nom   --Vers
        FROM taxonomie.bib_noms  
        WHERE cd_nom in (select cd_nom from taxonomie.taxref WHERE phylum ='Annelida')
    UNION SELECT 1001, id_nom   --Faune vertébrée
        FROM taxonomie.bib_noms  
        WHERE cd_nom in (select cd_nom from taxonomie.taxref WHERE phylum ='Chordata')
    UNION SELECT 4, id_nom   --Echinodermes
        FROM taxonomie.bib_noms  
        WHERE cd_nom in (select cd_nom from taxonomie.taxref WHERE phylum ='Echinodermata')
    UNION SELECT 101, id_nom   --Mollusques
        FROM taxonomie.bib_noms  
        WHERE cd_nom in (select cd_nom from taxonomie.taxref WHERE phylum ='Mollusca')
    UNION SELECT 303, id_nom   --Algues
        FROM taxonomie.bib_noms  
        WHERE cd_nom in (select cd_nom from taxonomie.taxref WHERE phylum in ('Charophyta', 'Chlorophyta', 'Rhodophyta'))
    UNION SELECT 1002, id_nom   --Faune invertébrée
        FROM taxonomie.bib_noms  
        WHERE cd_nom in (select cd_nom from taxonomie.taxref WHERE regne ='Animalia' AND phylum <>'Chordata')
    UNION SELECT 1004, id_nom   --Fonge
        FROM taxonomie.bib_noms  
        WHERE cd_nom in (select cd_nom from taxonomie.taxref WHERE regne ='Fungi')
    UNION SELECT 1003, id_nom   --Flore
        FROM taxonomie.bib_noms  
        WHERE cd_nom in (select cd_nom from taxonomie.taxref WHERE regne ='Plantae')
    UNION SELECT 100, id_nom   --Saisie Occtax
        FROM taxonomie.bib_noms
;		-- Manque encore Entognathes, 
		-- 				Pycnogonides, 
		-- 				Rotifères, 
		-- 				Tardigrades, 
		-- 				Lichens

-- check-up cor_nom_liste
SELECT bib_listes.id_liste, nom_liste, count(cor_nom_liste.id_liste) 
	FROM taxonomie.cor_nom_liste RIGHT JOIN taxonomie.bib_listes 
		ON cor_nom_liste.id_liste = bib_listes.id_liste
	GROUP BY bib_listes.id_liste, nom_liste
	ORDER BY bib_listes.id_liste;

