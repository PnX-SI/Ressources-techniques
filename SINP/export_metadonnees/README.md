# Usage

Export des métadonnées d'une base GeoNature vers le standard SINP métadonnées v1.3.10

* https://inpn.mnhn.fr/programme/donnees-observations-especes/references/standard-echange
* https://inpn.mnhn.fr/docs-web/docs/download/263030

# Installation de l'environnement

```sh
python3 -m venv venv
source venv/bin/activate
pip install psycopg2
pip install XlsxWriter
```

# lancement du script
```sh
python3 export_datasets.py
```