# OBSOCC -> OCCTAX

Pour simplifier l'écriture, pour la suite de document on notera :
- `OO` pour `OBSOCC`
- `GN` pour `GéoNaure`


# Configuration

## setting.ini

# Import des données

## Résumé des commandes

```
./import_obs_occ.sh
```

## Détails

Cette commande va effectuer les actions suivantes:

- Si `import_oo.cor_etude_protocole_dataset` n'existe pas:
  - Elle est crée

- Si `import_oo.cor_etude_protocole_dataset` n'a pas ses champs `id_data_set` renseignés:
  - Arrêt, message.

- TODO Intégration des données.

### Principes

On part d'un dumps de `OO`.
La base de GeoNature est présente.

- 1 : restoration de la base `OO`
- 2 : Création d'un schéma `OO export_gn`
  - Contient toutes les donnée formatée pour l'import des données dans `GN`
  - TODO détailller
- 3 : Création d'un `FWD` du schéma `OO export_gn` dans le schéma `GN import_oo` 

### Les jeux de données

#### But

Créer la table `import_oo.cor_etude_protocole_dataset` définissant les correspondances entre Jeux de données GéoNature, et études et protocoles de `OO`.

```
import_oo.cor_etude_protocole_dataset

id_protocole
id_etude
nom_etude
libele  // protocole
id_data_set
```

L'utilisation des tables etude et protocoles peux différer selon les cas.
Intégration automatique s'avère difficile.
On propose de créer une table de correspondance avec tous les couples  `id_protocole`, `id_etude` présent dans la table  `OBSOCC` `saisie.saisie_observation`.

Cette table est créée automatiquement avec des `id_dataset=NULL`.
Les champs `id_dataset` sont à compléter à la main.

Les JDD sont à créer dans le module GéoNature métodonnées.

#### Amélioration

- ??? Faire une interface de saisie pour la correspondance entre JDD et (etude, protocole)
- ??? Ajouter les organismes dans cor_etude_protocole_dataset
  - renommer en cor_dataset ?? 

### Les organismes / utilisateurs