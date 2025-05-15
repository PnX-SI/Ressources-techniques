# Génération de données d'import pour les protocoles monitorings

Ce script permet de générer des données d'un protocole monitoring pour tester l'import monitoring.

## Installation

```shell
source <dossierGeonature>/backend/venv/bin/activate
pip install -r requirements.txt
```

## Usage

Pour utiliser le script, voilà la commande minimale :

```shell
source <dossierGeonature>/backend/venv/bin/activate
python generate_data.py <identifiantProtocole> --cdnom-parent <cdNomParentPourGénérerLaListeDeTaxon>
```

Le fichier de données généré reprend le format suivant : `{PROTOCOL_NAME}_{NOMBRE_LIGNE}.csv`

**Exemple pour le protocole chiro**

```shell
python generate_data.py chiro --cdnom-parent 186233
```

## Paramètres

```plain
usage: Génération de données d'import pour les protocoles monitorings
       [-h] [--cdnom-parent CDNOM_PARENT] [--size-dataset SIZE_DATASET]
       [-s SITE_NB] [-v VISITE_NB] [-o OBSERVATION_NB]
       name_protocol

positional arguments:
  name_protocol         Nom du protocole monitoring

options:
  -h, --help            show this help message and exit
  --cdnom-parent CDNOM_PARENT
                        CdNom du taxon parent permettant de générer la liste
                        de taxon utilisée
  --size-dataset SIZE_DATASET
                        Nombre de lignes du fichier de sortie
  -s SITE_NB, --site-nb SITE_NB
                        Nombre de sites à générer
  -v VISITE_NB, --visite-nb VISITE_NB
                        Nombre de visites par site à générer
  -o OBSERVATION_NB, --observation-nb OBSERVATION_NB
                        Nombre d'observations par site à générer
```
