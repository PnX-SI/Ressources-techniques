Vérifier que les données contact faune et flore (source 1 et 7)
sont présentes en synthese (de part occtax)
et qu'il faut bien les supprimer de l'insert de v1_compat.syntheseff vers gn_synthese.synthese  

# Données de base

- [x] base avec le bon srid (pag/config/settings.ini)
- [ ] données ref_geo
  - [ ] commune, limites de parc
  - [ ] mnt

# Migration 

!!! gros problème avec bib_nom incomplet ?? -> occurences (sans cd_nom ????)

- [x] user

- [ ] Taxonomie 
  - [ ] bib_nom : clarifier le check_cdref et find_cd_ref(cd_nom) utilisé en find_cd_ref(cd_ref) 
  - [ ] voir à passer en 14 avant prod
  - [x] taxons exotique
  - [ ] taxons changés trouver le cd_nom qui va bien
    - [ ] 441839;"Évêque bleu-noir ";"Cyanocompsa cyanoides" ==> Cyanocompsa cyanoides = cd_nom:828942, cd_ref: 828943 (alors que le cd_nom 41839 pointe vers une espèce européenne)
    - [ ] 765714;"";"Combretum laxum" ==> nom_complet = "Combretum laxum Aubl." ==> cd_nom : 632627, cd_ref = 629395
- [ ] metadonnées

- [ ] gestion synonymes 
  - [x] Ai regénéré la totalité de cor_synthese_v1_to_v2 ==> l'ensemble des autres questions soivent y être soldées, non?
  - [ ] fonction pour verifier la cohérence (pas de plante larve)??? 
  - [ ] champ par defaut ==> ETAT_BIO = VIVANT
  - [ ] types
    - [ ] TYP_GRP 'OBS' pour tous les lot ??==> historique selon cor_synthesev1_to_v2. Par défaut en saisie: OBS
    - [ ] METH_OBS ==> historique selon cor_synthesev1_to_v2. Par défaut en saisie: VU (0)

- [ ] occtax 
  - [ ] cf. Synthese car données manquantes dans occTax... (vérifier auteur pour vérifier si saisie PAG)
  - [ ] données faune
    - [ ] releve
    - [ ] occurences
    - [ ] counting
    - [ ] user
  - [ ] données flore
    - [ ] releve
    - [ ] occurences
    - [ ] counting
    - [ ] user

- [ ] synthese
  - [ ] ATTENTION! seule une partie des données contactfaune/contactflore sont uniquement dans la synthese qui en compte 1627 faune + 272 flore alors que les jeux de données contactFaune = 121 et contactFlore = 205.
Peut-on les basculer vers occTax?

-------------Checkup données 26/03/2021
-[ ] Synthese
    - [ ] Importer données Contact Vertébré puis Contact Flore puis ce qui n'est ni dans l'un ni dans l'autre... (==> identification de ces données dans la synthese????)
	- [ ] SELECT * FROM gn_synthese.synthese WHERE id_source is null; ==> 507 données, en dataset 1 et 7. ==> problème à l'import ou à l'injection des données dans occTax ? car pas de données sans id_source dans GN19 
    	- [ ] SELECT id_module, id_dataset, count(*) FROM gn_synthese.synthese GROUP BY id_module, id_dataset ORDER BY id_module, id_dataset; ==> 1874 données avec des cd_nom mais pas de nom_cité. ==> 
    - [ ] SELECT * FROM gn_synthese.synthese WHERE cd_nom is null; ==> 105 données pr 57 taxons, toutes dans les jeux 1 et 7. Valeurs:
 	- [ ] SELECT nom_cite, synthese.cd_nom synth_cd_nom, taxref.cd_nom taxref_cd_nom
 		FROM gn_synthese.synthese LEFT JOIN taxonomie.taxref
 		ON synthese.nom_cite = taxref.lb_nom
		Where synthese.cd_nom is null
 		ORDER BY taxref_cd_nom,nom_cite ;
 	- [ ] Reste 3 taxons (avec faute de frappe car espace en fin de nom_cite): 
 		'Dacnis bleu '=> cd_nom = 441849
 		'Tangara des palmiers '=> cd_nom = 828962
		'Tangara évêque ' => cd_nom = 886020

-[ ] Validation

  
# Atlas

- [ ] schema
- [ ] virer medias GN
- [ ] test update