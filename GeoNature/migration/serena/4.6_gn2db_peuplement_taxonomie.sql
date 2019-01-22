-- Personnalisation du thème générique "Mon territoire" dans taxonomie.bib_themes
UPDATE taxonomie.bib_themes
	SET nom_theme='Parc XXX', desc_theme='Informations relatives au territoire du Parc XXXX'
	WHERE id_theme=1;


-- Ajout d'attributs "patrimonial" et "protege" liés au thème précédent (id_theme = 1) --> s'ajoute également dans l'interface de la fiche taxon de TaxHub
INSERT INTO taxonomie.bib_attributs(
	id_attribut, nom_attribut, label_attribut, liste_valeur_attribut, obligatoire, desc_attribut, type_attribut, type_widget, id_theme, ordre)
	VALUES (200, 'patrimonial', 'Patrimonial', '{"values":["oui","non"]}', false, 'Défini si le taxon est patrimonial pour le territoire', 'text', 'radio', 1, 5);
	
INSERT INTO taxonomie.bib_attributs(
	id_attribut, nom_attribut, label_attribut, liste_valeur_attribut, obligatoire, desc_attribut, type_attribut, type_widget, id_theme, ordre)
	VALUES (201, 'protege', 'Protégé', '{"values":["oui","non"]}', false, 'Défini si le taxon bénéficie d''une protection juridique stricte pour le territoire', 'text', 'radio', 1, 6);


-- Peuplement de la table taxonomie.bib_noms à partir de VM vm_bib_noms_inpn crée précedemment + les taxons observés dans la synthèse absents de la liste des espèces présentes en région (vm_bib_noms_inpn) --> essentiellement des rangs supérieurs (genre, famille, sous-ordre etc.) + dans notre cas, 2 taxons d'éspèces (Bruant à tête rousse et Bruant roux)
INSERT INTO taxonomie.bib_noms(
            --id_nom, 
            cd_nom, cd_ref, nom_francais)
(SELECT DISTINCT 
	a.cd_nom, a.cd_ref, a.nom_vern --, (cd_ref=cd_nom) as ref_actuel
  FROM _import_serena.vm_bib_noms_inpn as a
  --LEFT JOIN _import_serena.vm_bib_noms_territoire as b ON a.cd_nom = b.cd_nom
  ORDER BY a.cd_ref, a.cd_nom, a.nom_vern)
UNION
(SELECT DISTINCT 
	t.cd_nom, t.cd_ref, t.nom_vern
FROM  _import_serena.vm_obs_serena_detail_point a 
LEFT JOIN taxonomie.taxref t ON a.taxo_mnhn_id = t.cd_nom
LEFT JOIN _import_serena.vm_bib_noms_inpn b ON a.taxo_mnhn_id = b.cd_nom
WHERE b.cd_nom IS NULL
AND a.taxo_mnhn_id = t.cd_ref)
;

-- Peuplement de la table gn_synthese.taxons_synthese_autocomplete utilisée pour l'autocomplétion dans la recherche d'un taxon depuis la synthèse
-- Truncate préalable de la table /!\ VALABLE SEULEMENT SI 1ere INSTALL avec import des données exemples /!\
--TRUNCATE TABLE gn_synthese.taxons_synthese_autocomplete ;

INSERT INTO gn_synthese.taxons_synthese_autocomplete
SELECT DISTINCT t.cd_nom,
	  t.cd_ref,
  concat(t.lb_nom, ' = <i>', t.nom_valide, '</i>') AS search_name,
  t.nom_valide,
  t.lb_nom,
  t.regne,
  t.group2_inpn
FROM taxonomie.taxref t
JOIN gn_synthese.synthese s ON t.cd_nom = s.cd_nom;

INSERT INTO gn_synthese.taxons_synthese_autocomplete
SELECT DISTINCT t.cd_nom,
t.cd_ref,
concat(t.nom_vern, ' =  <i> ', t.nom_valide, '</i>' ) AS search_name,
t.nom_valide,
t.lb_nom,
t.regne,
t.group2_inpn
FROM taxonomie.taxref t  
JOIN gn_synthese.synthese s ON t.cd_nom = s.cd_nom
WHERE t.nom_vern IS NOT NULL;

-- Peuplement de la table de correspondance cor_taxon_attribut

-- Pour l'attribut 'Protégé'
INSERT INTO taxonomie.cor_taxon_attribut(
	id_attribut, valeur_attribut, cd_ref)
	(SELECT DISTINCT 201, 'oui', a.cd_ref 
	FROM taxonomie.bib_noms AS a
	JOIN _import_serena.vm_bib_noms_inpn AS b USING (cd_nom)
	WHERE b.cd_nom = b.cd_ref 
	AND (b.id_rang::text <> ALL (ARRAY['VAR', 'FO']::text[]))
	AND b.protege IS TRUE);
		 
-- Pour l'attribut 'Patrimonial' --> TO DO : compléter/valider la liste des espèces "patrimoniales"
INSERT INTO taxonomie.cor_taxon_attribut(
	id_attribut, valeur_attribut, cd_ref)
	(SELECT DISTINCT 200, 'oui', a.cd_ref 
	FROM taxonomie.bib_noms AS a
	JOIN _import_serena.vm_bib_noms_inpn AS b USING (cd_nom)
	JOIN _pnrx.especes_patrimoniales_pnrx AS c ON b.cd_nom = c.cd_nom);

													 
-- Peuplement de la table taxonomie.cor_nom_liste

-- Truncate préalable des tables (ATTENTION - VALABLE SEUELEMENT SI AUCUNES DONNEES DANS LES TABLES LIEES A bib_taxons -> 1ere INSTALL) 
--TRUNCATE TABLE taxonomie.cor_taxon_attribut ;
--TRUNCATE TABLE taxonomie.cor_nom_liste ;

-- Peuplement de la liste de taxons dont la saisie est possible dans OccTax (id_liste=1)
		 --> Les taxons déjà observés dans la synthèse des données du territoire + les autres taxons présents dans la liste INPN RA mais sans les synonymes 
INSERT INTO taxonomie.cor_nom_liste(
            id_liste, id_nom)							  
(SELECT DISTINCT 100, t.id_nom -- liste Saisie OccTax (tous les taxons DE REFERENCES potentiellement présents)
	FROM    taxonomie.bib_noms as t
	LEFT JOIN _import_serena.vm_bib_noms_territoire as p ON (t.cd_nom = p.cd_nom AND p.cd_nom = p.cd_ref)
	LEFT JOIN _import_serena.vm_bib_noms_inpn as i ON (t.cd_nom = i.cd_nom AND i.cd_nom = i.cd_ref)
	WHERE ((i.id_rang::text <> ALL (ARRAY['VAR', 'FO']::text[])) OR (p.id_rang::text <> ALL (ARRAY['VAR', 'FO']::text[])))
);

-- AUTRES EXEMPLES DE CREATION DE LISTES PERSONNALISEES :		

-- Création et peuplement d'une liste de taxons pour les rhopalocères et zygènes (papillons de jour)    
INSERT INTO taxonomie.bib_listes(
	id_liste, nom_liste, desc_liste, picto, regne, group2_inpn)
	VALUES (101, 'Rhopalocères', 'Liste des papillons de jour - Sous-ordre des rhopalocères', 'images/pictos/nopicto.gif', 'Animalia', 'Insectes');												 
INSERT INTO taxonomie.cor_nom_liste(
            id_liste, id_nom)	
(SELECT  101, t.id_nom -- liste des Rhopalocères et Zygènes
	FROM    taxonomie.bib_noms as t
	JOIN    _import_serena.vm_bib_noms_inpn as p ON t.cd_nom = p.cd_nom
	WHERE   p.famille in ('Papilionidae', 'Pieridae', 'Hesperiidae', 'Nymphalidae', 'Lycenidae', 'Zygaenidae'));
													 
-- Création et peuplement d'une liste de taxons pour les odonates   
INSERT INTO taxonomie.bib_listes(
	id_liste, nom_liste, desc_liste, picto, regne, group2_inpn)
	VALUES (102, 'Odonates', 'Liste des Odonates (libellules et demoiselles)', 'images/pictos/nopicto.gif', 'Animalia', 'Insectes');						  
INSERT INTO taxonomie.cor_nom_liste(
            id_liste, id_nom)							  
(SELECT  102, t.id_nom -- liste des Odonates
	FROM    taxonomie.bib_noms as t
	JOIN    _import_serena.vm_bib_noms_inpn as p ON t.cd_nom = p.cd_nom
	WHERE   p.ordre LIKE 'Odonata');

-- Création et peuplement d'une liste de taxons pour les EEE
INSERT INTO taxonomie.bib_listes(
	id_liste, nom_liste, desc_liste, picto, regne, group2_inpn)
	VALUES (666, 'Espèces invasives (EEE)', 'Liste nationale des Espèces Exotiques Envahissantes (EEE)', 'images/pictos/nopicto.gif', NULL, NULL);						  
INSERT INTO taxonomie.cor_nom_liste(
            id_liste, id_nom)							  
(SELECT  666, t.id_nom -- liste des EEE
	FROM    taxonomie.bib_noms as t
	JOIN    _import_serena.vm_bib_noms_inpn as p ON t.cd_nom = p.cd_nom
	JOIN 	_ref_inpn_listes.tr_ln_invasives_eee as eee ON p.cd_ref = eee.cd_ref);						  
						  
-- Création et peuplement d'une liste de taxons pour les espèces en listes rouges régionales
INSERT INTO taxonomie.bib_listes(
	id_liste, nom_liste, desc_liste, picto, regne, group2_inpn)
	VALUES (601, 'Liste Rouge Régionale Rhône-Alpes', 'Liste rouge régionale des espèces menacées pour la région Rhône-Alpes', 'images/pictos/nopicto.gif', NULL, NULL);
INSERT INTO taxonomie.cor_nom_liste(
            id_liste, id_nom)							  
(SELECT DISTINCT 601, t.id_nom -- liste des espèces en LRR
	FROM    taxonomie.bib_noms as t
	JOIN    _import_serena.vm_bib_noms_inpn as p ON t.cd_nom = p.cd_nom
	JOIN 	_ref_inpn_listes.v_lrr_ra as lrr ON p.cd_ref = lrr.cd_ref);					  
						  													 