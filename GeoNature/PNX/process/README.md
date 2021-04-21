# Process

Ici sont stockes les manip pour recreer les base des parcs depuis 0.
A clarifier!!

# Pré-requis

Créer le fichier 
- config.ini

```
geonature_DIR=~/info/app_gn/GeoNature/
ATLAS_dir=~/info/app_gn/GeoNature-atlas/ 
```

Dans le dossier config du parc (par ex `pag/config/`)

Creer les fichiers
- settings.ini (identique à celui de GN)
- geonature-config.toml (identique)


# Installation base

- joue install.sh
- installation des module du coeur (sans build)
- plus installe le `ref_geo` du parc si le fichier `<parc>/process_ref_geo.sh` existe

./install_db_all.sh <parc>


