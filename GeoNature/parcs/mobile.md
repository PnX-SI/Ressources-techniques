# Configuration pour les applications mobiles

La documentation pour les application mobile est disponible ici

[sync]()
[occtax mobile](https://github.com/PnX-SI/gn_mobile_occtax/blob/master/docs/installation-fr.md)


La route `/geonature/api/gn_commons/t_mobile_apps` permet d'obtenir la configuration pour les appli mobile d'un instance

Elle se base sur 

- la table `gn_commons.t_mobile_app`

| app_code | relative_path_apk | package | version_code |
|----------|-------------------|---------|--------------|    
| OCCTAX | static/mobile/occtax/occtax-1.1.4-generic-release.apk | fr.geonature.occtax | 2035|
| SYNC | static/mobile/sync/sync-1.1.2-generic-release.apk | fr.geonature.sync | 2485|

Les fichiers settings.json de l'arborescence suivante

```
- geonature
  - backend
    - static
      - mobile
        - occtax
          - settings.json
          - occtax-1.1.4-generic-release.apk
        - sync
          - settings.json       
          - sync-1.1.2-generic-release.apk
```

Le fichier occtax.json 

```
{
  "map": {
    "area_observation_duration": 365,
    "show_scale": true,
    "show_compass": true,
    "max_bounds": [[43, 5], [44, 6]
    ],
    "center": [43.2311510852, 5.4607754564],
    "start_zoom": 12.0,
    "min_zoom": 8.0,
    "max_zoom": 19.0,
    "min_zoom_editing": 10.0,
    "layers": [
      {
        "label": "IGN",
        "source": "/SCAN_25.mbtiles"
     },
     {
        "label": "Mailles 1x1",
        "source": "/maille1x1.gpkg"
     }
    ]
  }
}
```

Ajuster `center`, `max_bound`, `start_zoom`.
Pour les mailles le fichier maille1x1 doit être de la forme

Pour les layers:

- le fichier renseigné sera recherché dans l'arborescence du mobile

- pour voir la coloration selon la dernière observation
- le fichier maille1x1 doit être de type wkt ou geojson
  - wkt : `<id><geometry>` 
```
110,POINT (-1.5487664937973022 47.21628889447996)
108,POINT (-1.5407788753509521 47.241763083159455)
``` 
  - geojson: `FeatureCollection` ou tableau de `Feature`
```
{
  "type": "Feature",
  "geometry": {
    ...
  },
  "properties": {
  "id": 1234,
  ...    
  }
}
```

# Installation et utilisation 

- Télécharger l'application `sync`
  - Depuis le navigateur du mobile cliquer sur le lien `/geonature/static/mobile/sync/sync-1.1.2-generic-release.apk`

- Renseigner les url de Geonature et Taxhub

- Se connecter

- L'application propose d'installer Occtax mobile

- ...



# Mise à jour d'une application (doit être fait de concert pour toutes les instances)

- Sur le serveur
  - Changer les lignes de la table `gn_commons.t_mobile_apps` 
  - Rajouter les nouvelles version des apk pour les applications concernées.

- Sur le mobile
  - L'application propose un mise à jour. Suivre les instructions