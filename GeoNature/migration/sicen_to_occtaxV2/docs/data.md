# Les sripts SQL

Les script sql sont placés dans le dossier `data`

## Description du dossier `data`

- `csv` : 
  - `nomenclature.csv` : corrsepondance entre nomenclature `GN` et champs de la table `OO:saisie.saisie_observations.

- `draft` : brouillons

- `export_oo`: tous les script qui permettent de peupler le schéma `OO:export_oo` et de preformatter les donnée de `OO` pour prépoarer leur insertion dans `GN`

    - `user.sql`: vues `export_oo.v_utilisateurs_bib_organismes` et `export_oo.v_utilisateurs_t_roles`
    - `jdd.sql`: crée un table de correspondance entre `GN:id_dataset`, `OO:id_etude`, `OO:id_protocole`  ??? et `OO:id_structure`
    - `nomenclature.sql`: en cours

- `fdw.sql` : créer la liaison Foreign Data Wrapper entre les schémas `OO:export_oo` et `GN:export_oo`

- `insert` :  insères les données préformattées de `OO:export_oo` dans `GN`
  - `user.sql`: insère les données sur les organismes et uilisateurs
    - insertion des organismes
    - insertion des utilisateurs
    - creation d'un groupe `Grp_observateurs` pour les utilisateurs sans droit
    - 
    - (??? à affiner) assignation des droit:
      - `admin` -> `Grp_admin`
      - `expert` ou `amateur` -> `Grp_en_poste`
      - `observ` -> `Grp_observateurs`