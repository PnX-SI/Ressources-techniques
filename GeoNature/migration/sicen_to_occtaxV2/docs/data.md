# Les sripts SQL

Les script sql sont placés dans le dossier `data`

## Description du dossier `data`

- `csv` : 
  - `nomenclature.csv` : corrsepondance entre nomenclature `GN` et champs de la table `OO:saisie.saisie_observations.

- `export_oo`: tous les script qui permettent de peupler le schéma `OO:export_oo` et de preformatter les donnée de `OO` pour prépoarer leur insertion dans `GN`

    - `user.sql`: vues `export_oo.v_utilisateurs_bib_organismes` et `export_oo.v_utilisateurs_t_roles`
    - `jdd.sql`: crée un table de correspondance entre `GN:id_dataset`, `OO:id_etude`, `OO:id_protocole`  ??? et `OO:id_structure`
    - `oo_data`: crée un table qui regroupe toutes les données d'observations, pré-traite les dates

- `fdw.sql` : créer la liaison Foreign Data Wrapper entre les schémas `OO:export_oo` et `GN:export_oo`

- `insert` :  insères les données préformattées de `OO:export_oo` dans `GN`
  - `before_insert.sql`: créer des champs supplémentaires, désactive les triggers de la synthèse 
  - `user.sql`: insère les données sur les organismes et uilisateurs
    - insertion des organismes
    - insertion des utilisateurs
    - creation d'un groupe `Grp_observateurs` pour les utilisateurs sans droit
  - `media.sql`: insère les médias en base (le repertoire des médias à copier dans GéoNature et crée par un script bash)
  - `releve.sql`  
  - `occurence.sql`  
  - `counting.sql`  
  - `after_insert.sql`: réactive et rejoue les triggers de la synthèse

- `patch`: pour les jdd
  - `jdd_test`: (`-p='JDD_1'`) un seul JDD pour toutes les données 
  - `jdd_ep`:   (`-p='JDD_EP'` ou `-p='JDD_PE'`) un jdd par couple (protocole, etude)
    - `EP`: CA=etude, JDD=etude, protocole
    - `PE`: CA=protocole, JDD=protocole, etude

- `corect_oo.sql`: (option `-c`)
  - corrige la table `saisie.saisie_observation`:
    - correction des géométries avec `ST_BUFFER`
    - correction `date_max` < `date_min`  
    - correction `effectif_max` < `effectif_min` 