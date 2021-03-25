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
    - [ ] 765714;"";"Combretum laxum" ==> nom_complet = "Combretum laxum Aubl." ==> cd_nom : 4, cd_ref = 629395
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
  
# Atlas

- [ ] schema
- [ ] virer medias GN
- [ ] test update