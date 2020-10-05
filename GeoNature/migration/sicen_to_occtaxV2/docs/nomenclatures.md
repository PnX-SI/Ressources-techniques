# Correspondances entre nomenclatures `GN` et champs `OO`

## `nomenclature.csv`

- `data/csv/nomenclature.csv` : correspondance entre les champs suivants
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

Il faut d'une part 
- identifier ces correspondances 
- et d'autre part ordonner ces correspondance
  - si l'information d'une nomenclature depends de plusieurs champs on peut définir un ordre de priorité
    - on teste le premier champs
    - si l'information n'est pas dans le premier champs, on teste le deuxième champ
    - etc...
    - si on a pas d'information au bout du procesus, on défnit une valeur par défaut. 

### Les correspondances idntifiées : 
 
 Lien `code_type` <-> liste de `champs` de `OO:saisie.saisie_observation`

- `ETA_BIO` : `determniation`
- `METH_OBS` : `determination`
- `SEXE`: `phenologie`
- `STADE_DE_VIE`: `type_effectif`
- `STATUT_VALID` : `statut_validation`

### Valeur par défault

Si aucune correspondance ne peut ête trouvée, une valeur par défaut est assignée pour les valeurs obligatoires.

- TODO identifier les cas ou la valeur par défault est définie en base.
- TODO choisr els valeurs par défaut pour les autres cas.