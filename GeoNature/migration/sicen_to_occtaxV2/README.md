# OBSOCC -> OCCTAX


## IMPORTANT

**Procédure d'import en cours de développent.**

Travail effectué pour l'instant:

- table de correspondance des jeux de données
- intégration des organismes et des utilisateurs


Afin de simplifier l'écriture on notera :

- `OO` pour `ObsOcc`
- `GN` pour `GeoNature`
- `CA` pour cadre d'aquisition
- `JDD` pour jeux de données
- (`dev`) pour les actions de développement et de test d'intégration des données


Pour le nom des tables on utilise la notation suivante

``` APPLICATION:schema.table```

Par exemple : `OO:md.etudes` ou `GN:gn_synthese.synthese`

# Pré-requis

Avoir une base `GN` à la version 2.5.2 en bon état de fonctionnement.

Quelques corrections peuvent être apportée à la base `OBSOCC`

### Obligatoire

- Etre à jour de TaxRef V11.0 
- Etre sûr des fichiers medias (les champs url_photo ne pointent pas vers un fichier inexistant)

### Peut être gérer avec l'option `-c`

- Ne pas avoir de géométries invalides
- Pas de Date min > Date max
- Pas de Effectif min > Effectif max
 
# Configuration

## setting.ini

Avant toute chose, il faut créer et compléter le fichier `settings.ini`

- copier `settings.ini` depuis `settings.ini.sample`.

- modifier au besoin les lignes suivantes :

  - `db_host=localhost`
  - `db_port=5432`
  - `db_gn_name=geonature2` : nom de la base `GN` existante
  - `db_oo_name=obsocc` : nom de la base `OO` dans laquelle on placera le dump de la base obsocc d'origine, s'il n'existe pas le script peut retaure un fichier dump précisé par l'option `-f` ou `--dump-file`.
  - `user_pg=xxxx` : nom de l'utilisateur POSTGRESQL
  - `user_pg_pass=xxxx` : mot de passse POSTGRESQL


# Import des données

### Commande simple

La commande suivante permet d'intégrer les données de `OO` vers `GN` à partir du ficher dump de la base de données de `OO`

```
./import_obs_occ.sh -f <chemin vers le fichier du dump de la base `OO`>
```

### Correction de la base (option `-c`)

```
./import_obs_occ.sh -f <chemin vers le fichier du dump de la base `OO`> -c
```

Quelques élément sont corrigés automatiquement (date min/max, effectifs min/max, géométries non valides)

### Intégration des médias

- pour intégrer les médias on peut lancer cette commande avec les options suivantes

```
./import_obs_occ.sh -f <chemin vers le fichier du dump de la base `OO`> -m <chemin vers le dossier ds médias>
```

ici le dossier des médias est celui qui contient les répertoires `amateur`, `expert`, etc...

```
cp ./media/out/<nom de la base obscocc>/* <chemin_vers_geonature>/static/media/.
```

### les options (sortie de `./import_obsc.sh -h`) :
```
Usage: ./import_obsc.sh [options]
     -h | --help: display this help
     -v | --verbose: display more infos
     -x | --debug: display debug script infos
     -f | --oo-dump-file <path to obsocc dump file>
     -n | --gn-dump-file <path to geonature dump file>
     -d | --drop-export-gn: re-create export_oo schema
     -p | --patch: <"PATCH1|PATCH2|...">  (details below)
     -g | --db-gn-name: GN database name
     -o | --db-oo-name: OO database name
     -c | --correct-oo: correct OO:saisie.saisie_observation geometry and doublons 
     -e | --etude-ca: etude=cadre aquisition (par defaut protcole=cadre aquisition) 
     -z | --clean : clean previous attemps
     -m | --media_dir : path to media dir

     -p | --apply-patch

        Taxonomy     
 
            Sans cette options le script affiche les cd_nom non attribués et renvoie une erreur
            A partir de cette liste, on peut soit
              corriger les cd_nom dans la base obsocc
              choisir de les ignorer avec l'option qui suit

            TAX: ignore unassociated cd_nom


        Acquisition framework and datasets

            Il est conseillé de lancer le script sans cette option une première fois
            Il va permettre de voir la structure (protocole, etude, organisme) des données
            On peut alors relancer le script et choisir une des options suivantes

            JDD_1       1 CA 'test' and 1 JDD 'test' for all data (pour tester la migration)
            JDD_EP      CA = etude, and JDD = (etude, protocole) 
            JDD_PE      CA = protocole, and JDD = (protocole, etude) 

            Dans tout ces cas, il est conseillé d'éditer à post les jeux de données et cadres d'aquisition 
            afin de les renseigner au mieux

            Une autre option est de 
                créer les JDD depuis le module métadonnées 
                et de les assigner dans la table export_oo.cor_daset
           
        Exemple:

            ./import_obsocc <...autres options ...> -p "TAX|JDD1"
```

## Les actions de la commande

Cette commande va effectuer les actions suivantes :

### Restauration de la base `OO`

- Si la base de nom `${db_oo_name}` n'existe pas, on la crée à partir du fichier dump.
  - option `-f <path_to_dump_file>`
  - *Si on veut la re-créer il faut la supprimer à la main et relancer le script*.

### Création et remplissage du schéma `OO:export_oo`

- Si le schéma `OO:export_oo` n'existe pas:
  - Creation du schema `OO:export_oo`.
  - Création des vues et des table de `OO:export_oo`
  
- Ce schéma contient les vues et les tables pour préformater les données pour les insérer dans `GN`

- *(`dev`) On peut forcer la supression et le re-création avec l'option `-d`*

### Création du lien FWD entre `OO` et `GN`

- `OO:export_oo` -> `GN:export_oo`

### Vérification des correspondances entre `JDD`, études et protocole

- Si `GN:export_oo.cor_dataset` n'a pas ses champs `id_data_set` renseignés:
  - précision des lignes où l'`id_dataset` n'est pas renseigné.
  - Arrêt du script

- A ce stade il faut pouvoir renseigner la table `GN:export_oo.cor_dataset`. Voir le paragraphe sur les `JDD` pour plus de détails.

- *(`dev`) Avec l'option `-p JDD_1`, on peut créer un `CA` et `JDD` `test` et l'assigner à toutes les lignes de `GN:export_oo.cor_dataset` afin de testerla suite de l'intégration des données.*
- on peut choisir d'assigner 

### Intégration des données

  - Désactivatiopn des trigger synthèse
  - Utilisateurs et organismes.
  - Medias
  - Releves
  - Occurences
  - Dénombrements
  - Rejoue et reactive les triggers synthèse


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
id_data_set, 
id_structure ? 
```

L'utilisation des tables etude et protocoles peux différer selon les cas.
Intégration automatique s'avère difficile.
On propose de créer une table de correspondance avec tous les couples  `id_protocole`, `id_etude` présent dans la table  `OBSOCC` `saisie.saisie_observation`.

Cette table est créée automatiquement avec des `id_dataset=NULL`.
Les champs `id_dataset` sont à compléter à la main.

Les JDD sont à créer dans le module GeoNature métadonnées.

Une creation de jeux de données en fonction des etudes et protocoles est possbile (option `-p JDD_EP` ou `-p JDD_PE`) selon que l'on choisisse l'étude en tant que cadre d'aquisition (`JDD_EP`) ou le protocole (`JDD_PE`)


#### Améliorations

- Il peut être pertinent d'ajouter le champs `id_organisme` à cette table pour une gestion plus fine de ces JDD.
