# OBSOCC -> OCCTAX


## IMPORTANT

**Procédure d'import en cours de développent.**

Travail effectué pour l'instant:

- table de correspondance des jeux de données
- intégration des organismes et des utilisateurs


Afin de simplifier l'écriture on notera :

- `OO` pour `ObsOcc`
- `GN` pour `GéoNaure`
- `CA` pour cadre d'aquisition
- `JDD` pour jeux de données
- (`dev`) pour les actions de développement et de test d'intégration des données


Pour le nom des table on utilise la notation suivante

``` APPLICATION:schema.table```

Par exemple: `OO:md.etudes` ou `GN:gn_synthese.synthese`

# Pré-requis

Avoir une base `GN` à la version 2.5.0 en bon état de marche

# Configuration

## setting.ini

Avant toute chose, il faut créer et compléter le fichier `settings.ini`

- copier `settings.ini` depuis `settings.ini.sample`.

- modifier au besoin les lignes suivantes :

  - `db_host=localhost`
  - `db_port=5432`
  - `db_gn_name=geonature2` : nom de la base `GN` existante
  - `db_oo_name=obsocc` : nom de la base `OO` dans laquelle on placera le dump de la base obsocc d'origine, elle ne doit pas exister.
  - `user_pg=xxxx` : nom de l'utilisateur POSTGRESQL
  - `user_pg_pass=xxxx` : mot de passse POSTGRESQL


# Import des données

La commandes suivante permet d'intégrer les données de `OO` vers `GN` à partir du ficher dump de la base de données de `OO`

```
./import_obs_occ.sh -f <chemin vers le fichier du dump de la base `OO`>
```

les options (**obligatoire en gras**) :
 - **`f` : chemin vers le fichier du dump de la base `OO`**
 - `h` : descrition des options
 - `x` : mode `DEBUG`
 - `d` :(`dev`) suppression du schéma intermédiare `OO:export_oo` 
 - `p`: (`dev`) applique un `patch` sur les `JDD` 
   - un `CA`test et un `JDD` test sont crées
   - toutes les données ont le même JDD 
   - cela permet de tester la suite de l'intégration et de voir la viabilité du script.

## Les actions de la commande

Cette commande va effectuer les actions suivantes:

### Restauration de la base `OO`

- Si la base de nom `${db_oo_name}` n'existe pas, on la crée à partir du fichier dump.
  - *Si on veux la re-créer il faut la supprimer à la main et relancer le script*.

### Création et remplissage du schéma `OO:export_oo`

- Si le schéma `OO:export_oo` n 'existe pas:
  - Creation du schema `OO:export_oo`.
  - Crétion des vues et des table de `OO:export_oo`
  
- Ce shéma contient les vues et les tables pour préformarter les données pour les insérer dans `GN`

- *(`dev`) On peut forcer la supression et le re-création avec l'option `-d`*

### Crétion du lien FWD entre `OO` et `GN`

- `OO:export_oo` -> `GN:export_oo`

### Vérification des correspondance entre `JDD`, études et protocole

- Si `GN:export_oo.cor_dataset` n'a pas ses champs `id_data_set` renseignés:
  - précision des lignes où l'`id_dataset` n'est pas renseigné.
  - Arrêt du script



- A ce stade il faut pouvoir renseigner la table `GN:export_oo.cor_dataset`. Voir le paragraphe sur les `JDD` pour plus de détails.

- *(`dev`) Avec l'option `-p`, on peut créer un `CA` et `JDD` test et l'assigner à toutes les lignes de `GN:export_oo.cor_dataset` afin de testerla suite de l'intégration des données.*


### Intégration des données

  - Utilisateurs et organismes.
  - TODO


## Détails

### `JDD`
#### But

Créer la table `export_oo.cor_dataset` définissant les correspondances entre Jeux de données GéoNature, et études et protocoles de `OO`.

```
export_oo.cor_dataset

id_protocole
id_etude
nom_etude
libele_protocole
id_data_set
```

L'utilisation des tables etude et protocoles peux différer selon les cas.
Intégration automatique s'avère difficile.
On propose de créer une table de correspondance avec tous les couples  `id_protocole`, `id_etude` présent dans la table  `OBSOCC` `saisie.saisie_observation`.

Cette table est créée automatiquement avec des `id_dataset=NULL`.
Les champs `id_dataset` sont à compléter à la main.

Les JDD sont à créer dans le module GéoNature métodonnées.


#### Améliorations

- Il peut être pertinent d'ajouter le champs id_organisme à cette table pour une gestion plus fine de ces JDD.
- ??? Faire une interface de saisie pour la correspondance entre JDD et (etude, protocole)

### Les organismes / utilisateurs