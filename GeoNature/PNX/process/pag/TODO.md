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
    - [ ] 41839;"Évêque bleu-noir ";"Cyanocompsa cyanoides"
    - [ ] 765714;"";"Combretum laxum"
- [ ] metadonnées

- [ ] gestion synonymes (à vérifier!!!)
  - [ ] fonction pour verifier la cohérence (pas de plante larve)???
  - [ ] champ par defaut ?? (mieux dans l'INSERT ??) ?? ETAT_BIO VIVANT ou indefini par defaut??
  - [ ] types
    - [ ] TYP_GRP 'OBS' pour tous les lot ?? (à affiner par lot)
    - [ ] METH_OBS

- [ ] occtax 
  - [ ] données faune
    - [ ] releve
    - [ ] occurences
    - [ ] 
  - [ ] données flore

- [ ] synthese 

# Atlas

- [ ] schema
- [ ] virer medias GN
- [ ] test update