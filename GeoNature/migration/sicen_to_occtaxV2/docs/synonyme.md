# Correspondances entre nomenclatures `GN` et champs `OO`

## `data/csv/nomenclature.csv`

Correspondances entre les champs suivants :
   - `code_type` : type de nomenclature (par ex. `ETA_BIO` pour État biologique de l'observation)
   - `cd_nomenclature` : code de la nomenclature  ( part pour `ETA_BIO` `2` qui correspond à `Observé vivant`)
   - `obs_occ_value` : la valeur d'un champs de la table `OO:saisie.saisie_observation` 

Ce fichier est à remplir au mieux affin d'assurer un maximum de correspondance entre les champs de type nomenclature de `OCCTAX` et les données de `OBSOCC`.

Afin d'alléger ce fichier, et pour optimiser les correspondances, le test de correspondance se fera en comparant les valeurs du champs `obs_occ_value` se fera avec les transformations suivantes : 
- minuscule
- suppression des accents (par ex. `é`  -> `e`)
- ??? suppression du `s` à la fin.
- ...

## Correspondance multi champs

L'information sur une nomenclature peut venir de différents champs de la table `OO:saisie.saisie_observation` et un champs de
cette table peut contenir une information sur plusieurs types de nomenclature.

### Les correspondances identifiées : 
 
 Lien `code_type` <-> liste de `champs` de `OO:saisie.saisie_observation`
  Avec : 
    - type : le type de nomenclature
    - cor : le champs de la table `OO:saisie: saisie_observation`
    - la valeur (`cd_nomenclature`) assignée s'il n'y a pas de correspondance établie

#### Releve `GN:pr_occtax.t_releves_occtax`

- ??? `id_nomenclature_tech_collect_campanule`
  - type : `TECHNIQUE_OBS`
  - défaut : `133` (`Non renseigné`)

- `id_nomenclature_grp_typ`
  - type `TYP_GRP` 
  - defaut : `NSP` (`NSP`)


#### Occurrence `GN:pr_occta.t_occurrences_occtax`

  - `id_nomenclature_obs_technique`
    - type : `METH_OBS`
    - defaut : ???

  - `id_nomenclature_bio_condition`
    - type : `ETA_BIO`
    - cor : `determination`, `phenologie`
    - defaut : ???
  
  - `id_nomenclature_bio_status`
    - type : `STATUT_BIO`
    - defaut: `1` (`Non renseigné`)  

  - `id_nomenclature_naturalness`
    - type : `NATURALITE`
    - defaut : `0` (`Inconnu`)

  - `id_nomenclature_exists_proof`
    - type : `PREUVE_EXIST`
    - cor : `url_photo`
      - `1` (`Oui`) si `url_photo`
      - Sinon `0` `(Inconnu)`

  - `id_nomenclature_observation_status`
    - type : `STATUT_OBS`
    - default : `Pr` (`Présent`)

  - `id_nomenclature_blurring`
    - type : `DEE_FLOU`
    - default : `NON`

  - ??? id_nomenclature_diffusion_level
    - type : `NIV_PRECIS`
    - default : `0` : (`Standart`)
    - à changer selon les source et les sensibilités
    - à faire après l'import des données

  - ??? `id_nomenclature_source_status`
    - type : `STATUT_SOURCE`
    - ??? depuis le JDD

  - `id_nomenclature_behaviour`
    - type : `OCC_COMPORTEMENT`
    - cor : `comportement`
  
#### Dénombrement `GN:pr_occtax.cor_counting_occtax`
  
  - `id_nomenclature_life_stage`
    - type : `STADE_VIE`
    - cor : `type_effectif`, `phenologie`

  - `id_nomenclature_sex`
    - type : `SEXE`
    - cor: `phenologie`

  - `id_nomenclature_obj_count`
    - type: `OBJ_DENBR`
    - cor: `phenologie`, `type_effectif`

  - `id_nomenclature_typ_count`
    - type : `TYP_DENBR`
    - defaut : `NSP` (`Ne sais pas`)
