
# Mise à jour de la base de données Geotrek

Sommaire:
- [Mise à jour de la base de données Geotrek](#mise-à-jour-de-la-base-de-données-geotrek)
    - [Tronçons (`core_path`)](#tronçons-core_path)
    - [Correction des itinéraires](#correction-des-itinéraires-core_topology-where-kind--trek)
    - [Statuts](#statuts)
        - [Types fonciers (`landedge`)](#types-fonciers-landedge)
        - [Types de voie (`physicaledge`)](#types-de-voie-physicaledge)
        - [Correction des erreurs](#correction-des-erreurs)

## Tronçons (`core_path`)

**Scripts SQL associés** :
 *   [1.0_maj_core_path.sql](scripts_sql/import_new_troncons_geotrek/1.0_maj_core_path.sql)
 *   [1.1_maj_core_path_trigger.sql](scripts_sql/import_new_troncons_geotrek/1.1_maj_core_path_trigger.sql)
 *   [2.0_maj_core_pathaggregation.sql](scripts_sql/import_new_troncons_geotrek/2.0_maj_core_pathaggregation.sql)
 *   [2.1_maj_core_topology_trigger.sql](scripts_sql/import_new_troncons_geotrek/2.1_maj_core_topology_trigger.sql)

Une fois toutes les corrections réalisées, il faut importer la table `core_path_wip_new` dans la base de données Geotrek (ou une base test) dans le schéma `public`. Cet import peut se faire via les outils de QGIS ou [ogr2ogr](https://gdal.org/programs/ogr2ogr.html).

Une fois la table importée, les scripts [1.0_maj_core_path.sql](scripts_sql/import_new_troncons_geotrek/1.0_maj_core_path.sql) et [1.1_maj_core_path_trigger.sql](scripts_sql/import_new_troncons_geotrek/1.1_maj_core_path_trigger.sql) permettent de mettre à jour les données de Geotrek selon les étapes suivantes :
 * désactivation des triggers
 * mise à jour des géométries des `core_path` existants
 * insertion des nouveaux tronçons dans `core_path`
 * réactivation des triggers
 * simulation d'une mise à jour des géométries de `core_path` pour que les triggers se jouent et découpent tous les tronçons selon les règles de topologie de Geotrek.

Des erreurs sont susceptibles d'arriver : elles s'afficheront dans les *logs* des scripts mais ne seront pas bloquantes. Si les nettoyages et la supervision ont été correctement réalisées, on peut s'attendre à une erreur pour mille tronçons.

Avec la mise à jour de `core_path`, les tables `core_pathaggregation` et `core_topology` sont également mises à jour. Si on se connecte sur Geotrek-admin à ce moment, on peut observer qu'un certain nombre d'itinéraires de randonnée sont cassés : il manque des tronçons à certains endroits, ou bien l'altimétrie ne fonctionne pas, etc. C'est un résultat attendu de ces opérations, qui sont rarement sans conséquence sur l'intégrité des itinéraires. Les trous qui apparaissent dans certains itinéraires sont souvent le symptôme de `core_path` manquants dans `core_pathaggregation` : par exemple dans le cas d'un tronçon ayant été découpé en deux parties, parfois seule la moitié qui a conservé le même identifiant reste référencée dans `core_pathaggregation`, alors que l'autre moitié en est absente.

Avant de corriger à la main, via l'interface de Geotrek-admin, les itinéraires cassés, les scripts [2.0_maj_core_pathaggregation.sql](scripts_sql/import_new_troncons_geotrek/2.0_maj_core_pathaggregation.sql) et [2.1_maj_core_topology_trigger.sql](scripts_sql/import_new_troncons_geotrek/2.1_maj_core_topology_trigger.sql) permettent de minimiser le nombre de trous dans les `core_pathaggregation` des itinéraires, en retrouvant les tronçons manquants.

Deux tables `core_pathaggregation_to_insert` et `core_pathaggregation_new` sont créées. `core_pathaggregation_to_insert` contient les tronçons qui ont été repérés comme manquants à `core_pathaggregation`. `core_pathaggregation_new` agrège les données de `core_pathaggregation_to_insert` et celles de `core_pathaggregation` tout en réattribuant un ordre à chaque `pathaggregation` (colonne `order`). Le contenu de `core_pathaggregation` est ensuite remplacé par celui de `core_pathaggregation_new` après avoir désactivé ses triggers. Enfin, l'exécution de la fonction native de Geotrek `update_geometry_of_topology()` sur tous les enregistrements de `core_topology` permet de mettre à jour leur géométrie selon le nouveau contenu de `core_pathaggregation`.


L'ensemble du processus d'import est encapsulé dans un script bash `import_new_troncons_geotrek/run.sh`. En fonction de la taille des données à importer son exécution peut être longue (plusieurs heures).

Étapes :
 * Importer la table `core_path_wip_new` dans la base Geotrek
 * Copier le fichier [`settings.ini.sample`](scripts_sql/import_new_troncons_geotrek/settings.ini.sample) en `settings.ini` et renseigner les paramètres demandés
 * Lancer le script `run.sh`


## Correction manuelle des itinéraires

Il faut à présent corriger les itinéraires via l'interface de Geotrek-admin. On peut repérer ceux qui ont été cassés par les opérations précédentes avec la requête suivante, qui crée une table `treks_to_correct` les recensant. Cette table met également à disposition les URL d'édition et de visualisation de chaque itinéraire, ainsi que des champs `corrected` et `comments`. Ne pas oublier de renseigner vos propres URL dans cette requête avant de la lancer.

``` sql
CREATE TABLE treks_to_correct AS
WITH treks_broken AS (
SELECT id,
       'broken' AS problem
  FROM core_topology
 WHERE kind = 'TREK' -- repère les itinéraires dont la géométrie est cassée
   AND deleted = FALSE 
   AND (min_elevation = 0 -- grâce au calcul de l'altitude impossible
    OR ST_GeometryType(geom) != 'ST_LineString') -- ou à la géométrie qui n'est pas une LineString
    ),
treks_weird_new_length AS (    
SELECT ct.id,
       'length' AS problem
  FROM core_topology ct
  JOIN core_topology_ante cta -- table core_topology dans l'état précédent l'agrégation des linéaires (sauvegarde)
    ON ct.id = cta.id
   AND ct.kind = 'TREK' -- repère les itinéraires dont la longueur
   AND ct.deleted = FALSE
   AND (ct.length < (0.95 * cta.length) -- est inférieure
       OR ct.length > (1.05 * cta.length)) -- ou supérieure de 10% à sa longueur initiale (= avant agrégation des linéaires)
    ),
treks_to_correct_id AS (
SELECT id, problem FROM treks_broken
 UNION
SELECT id, problem FROM treks_weird_new_length twnl WHERE twnl.id NOT IN (SELECT id FROM treks_broken)
)
SELECT topo_object_id,
       name,
       'http://URL_ADMIN/trek/edit/' || topo_object_id AS edit_url, -- URL d'édition de l'itinéraire, changer URL_ADMIN par l'URL de l'Admin test sur lequel vous effectuez le processus
       'https://URL_RANDO/trek/' || topo_object_id AS rando_url, -- URL de l'itinéraire sur votre Geotrek-rando toujours connecté à votre base Admin inchangée. Permet de reconstruire facilement les géométries par comparaison avec cette géométrie initiale. Changer URL_RANDO par l'URL de votre Geotrek-rando
       problem,
       null::boolean AS corrected,
       null::varchar AS "comments"
  FROM trekking_trek tt
  JOIN treks_to_correct_id ttci
       ON ttci.id = tt.topo_object_id
       AND tt.published = TRUE;
```

Selon nos essais, parmi les itinéraires passant dans la zone d'intégration du nouveau réseau, 25% semblent intacts et 75% nécessitent une correction.

Si celle-ci se passe sans difficulté dans la majorité des cas, il peut arriver que l'interface d'édition de certains itinéraires n'affiche aucun tracé sur la carte, et que le bouton "Créer une nouvelle route" soit grisé. Un mécanisme sur lequel nous n'avons pas investigué semble en effet désactiver la visibilité de certains `core_path` lors des requêtes d'agrégation des réseaux. Le script corrige cela en rendant visibles tous les `core_path` présents dans un `core_pathaggregation`, mais si le problème d'édition persiste, il faut supprimer tous les `core_pathaggregation` de l'itinéraire concerné, à l'exception du premier et du dernier. Cela permet à priori d'afficher les points de départ et d'arrivée dans l'interface d'édition, puis de pouvoir recréer tout l'itinéraire manuellement :

``` sql
WITH
id_trek AS (
    SELECT /*identifiant de l'itinéraire*/ AS id
)
,a AS (
    SELECT max("order") AS max_order, -- Obtention du numéro d'ordre du dernier core_pathaggregation
           topo_object_id
      FROM core_pathaggregation, id_trek
     WHERE topo_object_id = id_trek.id
     GROUP BY topo_object_id
)
,b AS (
    SELECT path_id
      FROM core_pathaggregation cp
      JOIN a
        ON a.topo_object_id = cp.topo_object_id
       AND "order" IN (0, (max_order)) -- On ne garde que les premier et dernier core_pathaggregation
)
DELETE
  FROM core_pathaggregation cp
 WHERE topo_object_id = (SELECT id FROM id_trek)
   AND NOT path_id IN (SELECT path_id FROM b);
```

Enfin, on peut supprimer les tables créées par les scripts précédents grâce au script [3.0_clean_geotrekdb_corepath.sql](scripts_sql/import_new_troncons_geotrek/3.0_clean_geotrekdb_corepath.sql).

## Statuts

Si le linéaire importé comprend des informations attributaires sur le foncier et le revêtement, il est possible de les ajouter à la base de données après l'intégration des `core_path`.

Le processus présenté ici n'est pas générique car adapté aux données que nous avons intégré et à nos besoins de gestion (Parc national des Cévennes). Il peut néanmoins servir de base à modifier selon la structure de vos données.

Les scripts ayant servi à l'import de nos données sont situés dans le répertoire `import_status_geotrek`. Au préalable nous avons importé notre couche de données dans le schéma public de Geotrek dans la table `rlesi_cartosud_updated`.

Neuf champs de notre linéaire importé avaient un intérêt pour nous :
- `id` : identifiant du tronçon dans la couche source
- `proprio` : propriétaire de la voie
- `ref_cad` : référence cadastrale
- `code_cadas` : code cadastral
- `convention` : conventionnement de passage
- `statut_cad` : type de voie
- `type_revet` : type de revêtement
- `geom` : la géométrie du tronçon
- `layer` : le nom de la couche d'où est issu le tronçon (utilisé pour la tracabilité dans le champ `eid` de Geotrek, en combinaison avec l'id)

Pour que les scripts fonctionnent, il faut vous assurer que votre `rlesi_cartosud_updated` comportent bien sept champs nommés de cette manière et dont le contenu correspond à la description faite ci-dessus.

### Types fonciers (`landedge`)

**Script SQL associé** : [1_import_landedge.sql](scripts_sql/import_status_geotrek/1_import_landedge.sql)

Les requêtes présentes dans le script partent de deux postulats :
- chaque enregistrement/tronçon/entité des données importées correspondra à un enregistrement de la table `land_landedge` ;
- la liste des valeurs de `land_landtype` a été adaptée au préalable aux données importées (en l'occurrence le champ `statut_cad`).

Il faut s'assurer que le type "Inconnu" existe dans `land_landtype`, car il sera attribué si la valeur de `statut_cad` n'existe pas dans `land_landtype`.

La première étape consiste à insérer tous les enregistrements importés dans la table `core_topology`, qui constitue la base des objets de type foncier. Ensuite, le script insère ces enregistrements dans la table `land_landedge`, tout en rattachant ces `landedge` aux bonnes `core_topology` via leur géométrie. Maintenant que cela est fait, les `core_pathaggregation` de ces `core_topology` sont reconstruits en les projetant sur les `core_path`.

Des erreurs sont inévitables, mais nous avons fait le choix de les traiter après l'insertion des `land_physicaledge`.

### Types de voie (`physicaledge`)

**Script SQL associé** : [2_import_physicaledge.sql](scripts_sql/import_status_geotrek/2_import_physicaledge.sql)

Contrairement aux types fonciers – pour lesquels nous avons souhaité conserver le découpage juridique du réseau importé – la table `land_physicaledge` n'accepte qu'un champ attributaire : `physical_type_id`.

Nous avons trouvé inutilement lourd de représenter par exemple une même piste de gravier par plusieurs entités `land_landedge`, uniquement car elle a plusieurs propriétaires et donc est découpée en autant de tronçons juridiques. Nous avons donc fusionné les géométries des tronçons importés en les groupant par leur champ `type_revet`, à la condition que le résultat de la fusion soit une `LineString`.

La suite du processus est la même que pour les `landedge`, à l'exception qu'on utilise la table de géométries regroupées au lieu de la table d'origine comme base des requêtes.


### Correction des erreurs

**Scripts SQL associés** :
 * [3_detection_core_pathaggregation_manquants.sql](scripts_sql/import_status_geotrek/3_detection_core_pathaggregation_manquants.sql)
 * [3.1_insertion_core_pathaggregation_manquants.sql](scripts_sql/import_status_geotrek/3.1_insertion_core_pathaggregation_manquants.sql)
 * [4_detection_overlapping_landedge.sql](scripts_sql/import_status_geotrek/4_detection_overlapping_landedge.sql)

Il s'agit enfin de corriger les erreurs et manques restants dans la table `core_pathaggregation`. Pour cela, on cherche d'abord à corriger automatiquement les `landedge` et `physicaledge` comportant un trou : un `core_path` absent de `core_pathaggregation` en leur milieu.

A l'issue du script `3_correction_core_pathaggregation_manquants.sql`, la table `core_pathaggregation_manquants` représente les "trous".

Il faut superviser manuellement les cas où deux core_path ont été identifiés comme comblant le trou des core_pathaggregation (`SELECT * FROM core_pathaggregation_manquants WHERE compte = 2;`), afin de ne conserver qu'un seul des deux.

Une fois les éventuelles corrections effectuées, on peut insérer dans `core_pathaggregation` les `core_pathaggregation` manquants via le script `3.1_insertion_core_pathaggregation_manquants.sql`.


Une fois les `core_topology` trouées, donc ayant une géométrie en `MultiLineString`, corrigées, une autre phase de correction manuelle commence pour les `landedge` dont la géométrie chevauche celle d'au moins un tronçon importé. C'est le signe d'une erreur car nous sommes partis du postulat que chaque tronçon importé devait correspondre strictement à un `landedge`, soit une relation spatiale de type `ST_Equals()` et pas `ST_Overlaps()`. Pour cela, on crée une table `overlapping_landedge` qui stocke les endroits des erreurs sous forme de points avec le script `4_correction_overlapping_landedge.sql`.

Enfin, on peut corriger les erreurs de deux manières :
- dans Geotrek-admin, en modifiant les tracés de chaque `landedge` reconnu comme ayant une erreur ;
- dans un logiciel SIG et un logiciel d'administration de bases de données.

Cette seconde solution est sans doute la plus rapide, mais demande un peu de temps d'apprentissage de la manière de faire. En ayant les couches `core_topology`, `core_path`, `overlapping_landedge` et le réseau importé dans le logiciel SIG, on peut comprendre les erreurs et la correction à apporter. En modifiant directement la table `core_pathaggregation` dans le logiciel d'administration de BDD, on peut les corriger rapidement et de manière extrêmement précise. Les décalages entre `core_topology` et tronçons importés pouvant se compter en millimètres ou en mètres, il est bien plus efficace de corriger en base de données plutôt que via Geotrek-admin.

Les erreurs de `landedge` ou `physical_edge` sont parfois le symptôme d'erreurs de `core_path`. S'il est possible d'en profiter pour corriger ces dernières, il faut garder en tête que les `core_pathaggregation` peuvent s'en retrouver décalés, aussi il faut revérifier la cohérence des `core_topology` utilisant les `core_path` tout juste modifiés.
Cela est d'ailleurs valable de manière générale.

Une dernière vérification permet de s'assurer qu'itinéraires, types fonciers et types de voie n'ont pas été cassés par les dernières modifications :

``` sql
SELECT * FROM core_topology WHERE kind IN ('LANDEDGE', 'PHYSICALEDGE', 'TREK') AND (min_elevation = 0 OR ST_GeometryType(geom) != 'ST_LineString');
```

Enfin, on peut supprimer les tables utilisées pour l'import des statuts grâce au script [5_clean_geotrekdb_status.sql](scripts_sql/import_status_geotrek/5_clean_geotrekdb_status.sql).
