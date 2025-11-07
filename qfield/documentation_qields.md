Workshop - GTsi groupe géomaticien 
===================================


GROUPE INSTALLATION du QFieldcloud GTSI
---------------------------------------

Doc install QFieldCloud
-----------------------

Prérequis : Docker installé

Sources :

<https://geotribu.fr/articles/2024/2024-02-06_mise_en_place_serveur_qfieldcloud/#certificats-ssl>

<https://github.com/opengisch/QFieldCloud>

### Clonage du dépôt 

git clone \--recurse-submodules
<git@github.com:opengisch/QFieldCloud.git> 

Ou 

git clone --recurse-submodules
<https://github.com/opengisch/QFieldCloud.git> 

 

### Configuration du .env sous la racine de QFieldCloud 

cp .env.example .env 

 

Editer le fichier .env : 

QFIELDCLOUD\_HOST=\<nom\_serveur\> 

ENVIRONMENT=production 

SECRET\_KEY=\<valeur aléatoire\> (Cryptage des formulaires) 

DJANGO\_ALLOWED\_HOSTS=\"... \<nom\_serveur\>\" 

COMPOSE\_FILE=(remplacer le .local par .prod) 

 

### Installation des containers 

docker compose up -d --build 

docker compose exec app python manage.py migrate 

docker compose exec app python manage.py collectstatic 

 

### Configuration du certificat 

Commenter dans doker-compose.yml la section mkcert, puis

docker compose down \--remove-orphans 

apt install certbot 

source .env 

certbot certonly \--standalone -d \${QFIELDCLOUD\_HOST} 

Copie du certificat pour QFieldCloud :

sudo cp /etc/letsencrypt/live/\${QFIELDCLOUD\_HOST}/privkey.pem
./conf/nginx/certs/\${QFIELDCLOUD\_HOST}-key.pem 

sudo cp /etc/letsencrypt/live/\${QFIELDCLOUD\_HOST}/fullchain.pem
./conf/nginx/certs/\${QFIELDCLOUD\_HOST}.pem 

docker compose up --d 

 

Le certificat expire tous les 3 mois, il nécessite donc un
renouvellement.

Cerbot install un cron qui assure le renouvellement
/etc/cron.d/certbot : 

0 \*/12 \* \* \* root test -x /usr/bin/certbot -a \\! -d
/run/systemd/system && perl -e \'sleep int(rand(432

00))\' && certbot -q renew \--no-random-sleep-on-renew 

=\> 2 fois par jour, certbot vérifie la validité du certificat 

Il est donc nécessaire de créer un cron qui assure la copie du
certificat déposé sous /etc/letsencrypt ver
/\<path\_qfieldcloud\>/conf/nginx/certs :

sudo crontab -e 

Ajouter ces 2 lignes : 

30 2 \* \* \* source /\<path\_qfieldcloud\>/.env &&
cp /etc/letsencrypt/live/\${QFIELDCLOUD\_HOST}/privkey.pem
./conf/nginx/certs/\${QFIELDCLOUD\_HOST}-key.pem 

30 2 \* \* \* source /\<path\_qfieldcloud\>/.env && sudo cp
/etc/letsencrypt/live/\${QFIELDCLOUD\_HOST}/fullchain.pem
./conf/nginx/certs/\${QFIELDCLOUD\_HOST}.pem 

=\> Tous les jours à 2:30, copie du certificat 

Projet création de données depuis une base : Occhab
===================================================

#### Créer des champs avec des relation N-N (exemple de mutltiples observateur sur une station) :

Voir la doc de
QGIS<https://docs.qgis.org/3.40/en/docs/user_manual/working_with_vector/joins_relations.html#many-to-many-n-m-relations>

⚠️ Comme on écrit dans deux tables en meme temps (et qu'il est
necessaire d'avoir les FK liant les deux tables, il est necessaire de
spécifier à QGIS qu'il doit faire lancer les requêtes dans une
transaction ) : Dans Projet → propriété du projet , selectionner
« groupe de transaction mises en mémoire tampon »

pour que les valeur « DEFAULT » soient délégués à PostgreSQL,
selectionner « évalur les valeurs par défaut depuis le fournisseur de
donnés »

![](./qfield_doc_img/img/10000001000002860000009B9DC33082.png){width="6.6929in"
height="1.6055in"}

QFIELD Cloud
============

Gestion des droits
==================

<https://docs.qfield.org/reference/qfieldcloud/concepts/>

Il faut distinguer les droits associés à la gestion du QGisCloud et les
droits associés aux utilisateurs d\'un projet.

Tout utilisateur est déclaré dans \"Core / People\".

### Côté QGisCloud

Un utilisateur peut être associé à un groupe (\"Authentication and
Authorization / Group\"). Le groupe correspondant un ensemble
d\'autorisation relatif à la gestion du QGisCloud.\
Par défaut, il n\'y en a pas et l\'utilisateur admin est déclaré comme
superuser.\
Dans le cadre des parc nationaux, il faudra évaluer la nécessité et
créer un groupe pour les administrateurs de chaque parc où de déclarer
chaque admin comme superuser.\
Globalement, chaque objet QFieldCloud offre les droits suivants :

-   can add
-   can change
-   can delete
-   can view

### Côté projet

Il est possible de définir une organisation (\"core / Organization\")
qui dans le cadre des parc nationaux pourrait correspondre à chaque parc
(PNPC, PNFor, PNP\...)

A l\'intérieur de ces organisations, il est possible de définir une ou
plusieurs équipes (\"core / Team\") qui sont eux même peuplés par une
liste d\'utilisateur.

C\'est ensuite au niveau du projet (\"core / project\") qu\'il est
possible d\'y associer une ou plusieurs équipes.

Toutefois, il est possible de rattacher directement des utilisateurs aux
projets.

Pour chaque utilisateur ou equipe rattaché à un projet, il est possible
de lui définir son niveau d'autorisation :

-   admin : Peut renommer et supprimer le projet. Possède les même
    droits que le propriétaire du projet
-   manager : Peut ajouter ou supprimer des collaborateurs
-   editor : Peut éditer des connées
-   reporter Peut seulemnt ajouter des donnée, pas le droits de
    modificaiton ou de suppression
-   reader : Lecture seule

###

L'utilisateur ne peut voir que les projets rattachés à son équipe (ou à
lui directement) ainsi que les projets déclarés comme public. Dans ce
second cas, depuis QFielf mobile, il apparaitra dans l'onglet
« Communauté » mais il ne pourra pas faire de modification.

![](./qfield_doc_img/img/100000010000041100000304685B92BE.png){width="6.6402in"
height="5.028in"}

Sources :
<https://docs.qfield.org/reference/qfieldcloud/concepts/#gallery>

### Le concept d\'email

Lors de la création d\'un utilisateur, si un email lui est renseigné,
l\'utilisateur a alors la possibilité de se connecter avec son
identifiant ou avec son adresse email.

QFieldCloud permet, depuis \"Accounts / Email addresses\" de définir
plusieurs adresses emails pour un même utilisateur. Ainsi, il est
possible de s\'authentifier comme étant l\'utilisateur X à partir de
plusieurs adresses et avec un même mot de passe.

L\'intérêt de cette possibilité reste en suspend dans le contexte parcs
nationaux.

###

### Concept des plans et subscriptions

Pour la solution QFieldCloud --- y compris quand elle est
**autohébergée** (self-hosted) --- il est utile de bien distinguer les
notions de **« plan »** et **« subscription / abonnement »**, car elles
répondent à des rôles différents. Voici un résumé clair avec leurs
intérêts et implications.

### 🎯 Qu'est-ce qu'un « plan »

Un *plan* (forfait) définit **le niveau d'offre** : les fonctionnalités,
les limites (stockage, utilisateurs, collaboration privée, etc.), le
type d'usage permis.\
Par exemple, pour QFieldCloud hébergé par le fournisseur cloud :

-   Le plan *Community* gratuit : projets publics / privés illimités,
    mais stockage limité, pas de support avancé, pas d'édition hors
    ligne de couches PostGIS.
    [qfield.cloud+2qfield.cloud+2](https://qfield.cloud/faq.html?utm_source=chatgpt.com)
-   Le plan *Pro* (payant) : fonctionnalités supplémentaires (ex.
    édition hors ligne PostGIS) [qfield.cloud+2QField
    community+2](https://qfield.cloud/pricing?utm_source=chatgpt.com)
-   Le plan *Organization* : pour équipes, gestion des membres,
    collaboration, tarification par utilisateur actif.
    [QField+1](https://docs.qfield.org/get-started/storage-qfc/?utm_source=chatgpt.com)
-   Dans le contexte autohébergé, bien que vous gériez votre propre
    infrastructure, la notion de plan reste pertinente si vous appliquez
    une structure de tarification ou de niveaux internes, ou si vous
    utilisez la version «hébergée» comme référence.

**Intérêt du plan**

-   Il permet de clarifier ce que l'on peut faire ou non (ex. nombre
    d'utilisateurs, collaboration privée, accès en hors-ligne PostGIS).
-   Il sert à dimensionner l'infrastructure ou l'abonnement/licence
    correspondante.
-   Il rend la proposition de valeur visible (ce que j'obtiens si je
    choisis ce niveau).
-   Il permet de faire évoluer l'usage (ex. passer du plan «Community»
    au plan «Pro»).

### 🔁 Qu'est-ce qu'une « subscription / abonnement »

Une *subscription* est le mécanisme par lequel on **active** un plan
payant et on paie pour l'usage de ce plan selon une périodicité
(mensuelle, annuelle, etc.).
[qfield.cloud+1](https://qfield.cloud/tos.html?utm_source=chatgpt.com)\
Même dans un contexte autohébergé, la notion peut exister : par exemple,
vous hébergez QFieldCloud vous-même mais pouvez souscrire à un support
professionnel ou à des fonctionnalités additionnelles liées au logiciel
ou au service.

**Intérêt de l'abonnement**

-   Il fixe l'engagement financier et périodique pour bénéficier du
    plan.
-   Il permet de suivre la facturation, la durée, la résiliation.
-   Il donne accès aux mises à jour, au support, à certaines options
    (exemple : stockage supplémentaire, utilisateurs actifs).
    [QField+1](https://docs.qfield.org/get-started/storage-qfc/?utm_source=chatgpt.com)
-   Il facilite la gestion administrative (facturation, licences) pour
    l'organisation.

### 🧐 Particularités pour l'autohébergement

Quand vous autohébergez QFieldCloud, voici quelques nuances importantes
:

-   Vous contrôlez toute l'infrastructure (serveur, base de données,
    stockage, réseau) : voir guide d'installation.
    [Geotribu+1](https://geotribu.fr/articles/2024/2024-02-06_mise_en_place_serveur_qfieldcloud/?utm_source=chatgpt.com)
-   Bien que la version autohébergée soit libre (open-source) et sans
    payer directement le service hébergé, certains modules liés aux
    plans ou abonnements peuvent toujours apparaître (gestion des
    utilisateurs, "active user", fonctionnalités payantes). Par exemple,
    un article mentionne qu'il faut parfois manipuler la table
    *subscription\_subscription* pour remettre le statut «active\_paid»
    dans une instance self-hosted.
    [Geotribu](https://geotribu.fr/articles/2024/2024-02-06_mise_en_place_serveur_qfieldcloud/?utm_source=chatgpt.com)
-   Si vous utilisez l'infrastructure officielle hébergée (cloud) alors
    la tarification «plan» / «subscription» est clairement définie. Pour
    l'autohébergement, vous devez internaliser : plan interne + coût de
    maintien + licences éventuelles + support.

### ✅ En résumé

-   **Plan** = quel niveau d'usage/fonctionnalités vous choisissez.
-   **Subscription** = la façon de payer périodiquement pour ce plan.
-   Dans l'autohébergement, le plan est un choix de niveau (même s'il
    n'est pas facturé par un fournisseur externe), l'abonnement peut
    être interne (ex. support/licence) ou rendre compte d'un fournisseur
    tiers (si vous achetez un service complémentaire).
-   Bien vérifier : utilisateurs actifs, stockage, édition hors‐ligne,
    PostGIS, etc. (voir FAQ)

###

### Gestion des quotas

Des quotas peuvent être définis soit globalement (à travers les
\"Subscription / Plans\" et \"Subscription / Subscription\") ou
localement à un projet.

#### Les quotas globaux

Un plan peut être assimilé à un forfait auquel il faut que les
utilisateurs doivent souscrire

Par défaut, deux \"plans\" sont définis dans QFieldCloud :

-   Community : c'est le plan par défaut aui est attribué aux
    utilisateur lors de leur création
-   Organization : c'est celui par défaut qui est attribué lors de la
    création d'une organisation

Au regard de la valeur du champ « Ordering », il semblerais que ce soit
le forfait « community » qui s'applique même si l'utilisateur est
associé à une organisation. Se pose la question de quand le forfait
« Organisation » prend le dessus ?

Dans un contexte PNx, il n'y aurait pas besoin de créer d'autre type de
forfait. Ainsi, les resssources et l'espace disque serait partagé entre
tous. Les quota de ressources attribué à chaque forfait seraient à
ajuster en fonction des capacité du serveur hôte.

Il pourrait être envisagé qu'un (ou deux) administrateurs dans les PNx
soient désignés pour gérer le serveur. Seul eux aurait des accès pour
éditer les forfaits (à travers un groupe dédié) car au plus proche
suivre le niveau d'usage du serveur.

Fonctionnement à connaître :

-   Lors de la création d'un utilisateur, ce dernier est souscrit
    automatiquement au forfait « community »
-   Lors de la création d'une organisation, cette dernière souscrit
    automatiquement au forfait « Organization »

Si un utilateur est propriétaire d'un projet, alors il prend les
réglages associé au forfait community auquel il est rattaché par défaut.
Cependant, si un utilisateur fait partie d'une organisation et qu'il est
déclaré « organization member admin » de celle-ci alors il peut créer un
projet en mettant son organisation en tant que propriétaire du projet :
dans ce cas c'est les réglages du forfait Organization qui sont utilisé.

IMPORTANT : Afin de permettre la saisie direct dans des bases postgreSQL
/ Postgis il faut penser à cocher l'option « Is external db supported »
dans le Plan « Community »

PROJETGIS =\> PROJET QFIELD
===========================

***Les projets proposés au cours du workshop***

Projet consultation :

Nom du projet : projet\_visualisation

-   zonage (ref\_geo) :
    <https://www.data.gouv.fr/datasets/contours-des-11-parcs-nationaux-de-france/#/resources/bb4cda9a-9036-4458-9113-e05b923f0656>

```{=html}
<!-- -->
```
-   Aménagements :

    -   localisation signalétique (Connexion BDD Geotrek PNFor)

```{=html}
<!-- -->
```
-   -   passerelle (Connexion BDD Geotrek PNFor)

-   Risques naturels

    -   vigie crue (API) :
        <https://www.vigicrues.gouv.fr/services/InfoVigiCru.geojson>

    -   Lien doc Flux VigiEau :
        <https://resana.numerique.gouv.fr/public/information/consulterAccessUrl?cle_url=1815913141D2MCZAQMVT5VaVNjB2sDJwBsU2EPLgY/CmUHYlc/ADgPOwM0UDJYbQFhB2gFNw>==

        -   Commande python :
            QgsProject.instance().addMapLayer(QgsVectorLayer
            (\"/vsicurl/https://regleau.s3.gra.perf.cloud.ovh.net/pmtiles/zones\_arretes\_en\_vigueur.pmtiles\",
            \"zones\_restriction\", \"ogr\"))

    -   BRA, pas pertinent sur le parc PNFor =\> Station météo :
        <https://public-api.meteofrance.fr/public/DPClim/v1/liste-stations/infrahoraire-6m?id-departement=52&parametre=precipitation>
        (token valable une heure).

\- données naturalistes (GeoNature)

-   fond de carte hors ligne (mutualisation entre les projets) : mbtiles
    PNFor
-

Projet Saisie dans postgis

\- polygones avec snapping : habitat/zones humides

\- formulaire complexe avec des listes déroulantes (issues de BD)

\- rendu dynamique (style/information qui s'adapte en fonction de la
saisie)

\- trace et jalon : gpslike

-   point avec photo

Connexion au serveur QField cloud depuis QGis

Prérequis : installation de l'extension QFieldSync

![](./qfield_doc_img/img/100000010000004900000043A56B8FBE.png){width="0.7602in"
height="0.698in"}![](./qfield_doc_img/img/100000010000027F000002B7B757BCD0.png){width="2.4138in"
height="2.6366in"}

L'accès à la zone de saisie pour renseigner l'URL se fait par un double
clic sur le logo

![](./qfield_doc_img/img/1000000100000276000002B41F673C3E.png){width="3.3327in"
height="3.6665in"}

Connexion avec une base postgis
===============================

<https://github.com/opengisch/QField/discussions/2508>

\
L\'utilisateur admin créé lors de l\'installation est associé au \"Plan
Community\". Il faut activer le paramètre \"is external db supported\"
dans ce plan

![](./qfield_doc_img/img/10000001000004000000023DD52A8581.png){width="6.6929in"
height="3.7453in"}

Créer un projet qfield vierge dans QGIS

![](./qfield_doc_img/img/100000010000027D000002BEBBCDE7A5.png){width="4.5839in"
height="5.0398in"}

Après avoir cliqué sur \"Next\", renseigner le champ name (par le nom
que l\'on souhaite donner au projet)

Définir l\'emplacement local du projet

![](./qfield_doc_img/img/100000010000027D000002BE6D776A2A.png){width="4.0681in"
height="4.4819in"}

Cette étape créé un dossier vide au niveau de l\'emplacement définit
dans \"Local Directory\"

Ensuite, depuis QGIS, créer son projet en ajoutant les couches
souhaitées (dont la couche postgis)

Dans les \"paramètres du projet QField\" attribuer \"Offline editing\"
pour la couche postgis

![](./qfield_doc_img/img/1000000100000400000002F0807A4492.png){width="6.6929in"
height="4.9146in"}

Enregistrer le projet dans le dossier définit dans le local \"Local
Directory\"

Publier le projet dans QField

![](./qfield_doc_img/img/1000000100000400000002ADDB0D65BA.png){width="6.6929in"
height="4.4772in"}

Une fois le projet publiée, la couche du projet QGis n\'est pas
transformée en gpkg, elle reste un lien vers la base de données.

Lors de la récupération du projet sur le terminal mobile si une erreur
apparait Permission denied, plan is insufficient c\'est que votre
utilisateur n\'a pas les permissions d\'accéder à une base externe. Ce
paramètre est géré par le plan auquel souscrit l\'utilisateur. Il faut
le changer de plan ou ajouter la permission is\_external\_db\_supported
au Plan (<https://github.com/opengisch/qfieldcloud/issues/870>)

**

La partage de fond de cartes entre projet QField
================================================

Le principe est d'avoir un fond de carte unique sur le smartphone qui
puisse être exploité par plusieurs projet QField.

Pour cela, lors de la préparation du projet dans QGIS, il faut indiqué
dans les Préférences / options, onglet « Source de données » un chemin
de données localisé devant correspondre à l'emplacement du fond de carte
sur le pc.

Exemple avec un fond de carte stocké localement sur le PC :

![](./qfield_doc_img/img/100000010000053C00000308D1E18C65.png){width="6.6929in"
height="3.8756in"}

Il faut ensuite déposer une première fois le fichier du fond de carte
sur le smartphone, dans le dossier
« Android/data/ch.opengis.qfield/files/QField/basemaps » qui se trouve
dans le stockage interne.

Vu que le fond de carte ne doit pas être packagé, il faut commencer par
créer un projet QField vierge

![](./qfield_doc_img/img/100000010000028C000002BECE552C66.png){width="6.6929in"
height="7.2063in"}

Ajouter ensuite le fond de carte puis les couches.

Dans le cas d'un ajout de couche sous forme de fichier, il faut
préalablement les intégrer ou les convertir en geopackage qui devra être
stocké à l'intérieur du dossier du projet qfield (définit lors de la
création du projet vierge)

Ce sont les fichier gpkg qui devront être utilisé dans qgis pour créer
le projet QField

Pour la publication du projet dans QFieldCloud :

![](./qfield_doc_img/img/1000000100000400000002ADDB0D65BA.png){width="6.6929in"
height="4.4772in"}

Les formats supportés : jp2, tiff et mbtiles.

Petite subtilité sur le format mbtiles, si le fichier mbtiles n'a pas
été généré par QGIS, il se peut qu'il ne soit pas lu par qfield !!!

Partage des fonds de cartes entre QField, OccTax et OruxMap
-----------------------------------------------------------

Il est possible de déplacer l'emplacement du dossier basemaps de QField
sur la carte SD ou sur le stockage interne.

Pour cela, depuis les paramètres du téléphone, aller dans application et
rechercher QField. Entrer dedans et appuyer sur « Stockage ». Sur cette
interface, il est possible d'appuyer sur « Modifier » choisir « Carte
SD ». Patientez jusqu'à la fin de la copie.

![](./qfield_doc_img/img/1000000100000438000009600B3EFBBD.png){width="2.7693in"
height="5.9701in"}

Aprsè ça, le dossier basemap se trouve sur la carte SD, dans le dossier
Android/data/ch.opengis.qfield/files/QField/basemaps.

Il est ainsi possible de partager le fond de cartes entre QField et
OccTax.

Si les fonds Occtax, ont été initialement stockés dans un dossier
mapfiles qui est ensuite indiqué dans les fichiers de conf de GN, il est
conseillé de conserver ce dossier mapfiles vide. Occtax sera en mesure
d'aller chercher les fonds désormais situé dans le dossier basemaps de
Qfiled.

Il est aussi possible et plus propre de refaire les fichiers de config
de GN.

Par contre, OruxMap ne semble pas pouvoir accéder au fond de carte
contenu dans ce dosier basemap car il n'est pas possible de faire
pointer l'option « Options globales / Carte / Dossier cartes » vers ce
dossier.

TEST TRACKING
=============

Doc Qfield :
<https://docs.qfield.org/how-to/navigation-and-positioning/tracking/>

Pour enregistrer une trace dans le projet Qfield, une couche ligne /
polyligne doit être créée au préalable et déposer dans le projet.

Le suivi peut se paramètrer de 2 façon :

-   manuelle : depuis qfiled, clique long sur la couche, démarrer le
    suivi et associer les paramètres souhaités. Un symbole
    ![](./qfield_doc_img/img/100000010000003100000031036058AC.png){width="0.3402in"
    height="0.3402in"} apparaît à côté de la couche. Pour arrêter le
    suivi, il faut alors appuyer sur ce petit bonhomme et arrêter le
    suivi. Il est aussi possible de reprendre le suivi.
-   Automatique : le paramètre se fait dans QGIS depuis la propriété de
    la couche. Il faut ensuite renseigner les paramètres

![](./qfield_doc_img/img/10000001000005FA0000012DA7487B4F.png){width="6.6929in"
height="1.3165in"}

Cette fonctionnalité peut servir à saisir des geom depuis un suivi de
géolocliasation.

Il est aussi possible de connecter sa localisation qfield à un RTK.

TEST mise à jour automatique
----------------------------

Depuis Qfield, et pour cahque projet, il est possible de paramétrer
l'envoi automatique des modifications toutes les 30 minutes.

Test réalisé : création de 2 couches en dur déposé dans le projet. Modif
des 2 couches avec 2 utilisateurs différents =\> pas convainquant. A ne
pas privilégier

QField -- Formulaire -- Filtrer un champ select sur la base d'un choix sur une autre table
==========================================================================================

Situation :
-----------

On a une couche « t\_habitat » qui possède un champ pointant vers une
table « habref » qui elle est lié à une table « typoref ».

L'idée est de pouvoir filtrer dans le formulaire habitat le select de
l'habitat en fonction d'une typologie d'habitat.

Déclaration des jointures dans QGis
-----------------------------------

Il faut créer une table intermédiaire, ici nommmé « select\_typo »
composé d'un champ id et d'un champ cd\_typo.

Dans les **propriétés **du **projet** qgis, aller dans l'onglet « Source
de données » et déclarer le relation entre les table :

-   t\_habitat (cd\_hab) -- habref (cd\_hab)
-   habref (cd\_typo) -- typoref (cd\_typo)
-   select\_typo (cd\_typo) -- typoref (cd\_typo)

Paramétrage du formulaire
-------------------------

### Table « select\_typo »

Ouvrir les propriétés de la couche « select\_typo » aller dans l'onglet
« Formulaire ».

-   Dans la barre du haut, choisir « Conception par glisser/déplacé »

-   dans « Form Layout » ne conserver que « cd\_typo »

-   Dans les types d'outil associés au champ

    -   Choisir Valeur relationnelle
    -   couche = typoref
    -   colonne clé = cd\_typo
    -   colonne de valeur = lb\_nom\_typo

![](./qfield_doc_img/img/10000001000006B400000325BDAD8617.png){width="6.6929in"
height="3.1398in"}

Validez la configuration du formulaire en cliquant sur « OK »

### Table habitat

Sur le même principe, aller dans le paramétrage du formulaire dans les
propriétés de la couche « t\_habitat »

-   sélectionner « Conception par glisser/déplacé »

-   Cliquer sur le champ « cd\_hab »

-   Choisir le type d'outil « Valeur relationnelle »

    -   couche = habref

    -   colonne clé = « cd\_hab »

    -   Colonne de valeurs = « lb\_hab\_fr »

    -   Ajouter une expression de filtre :

        -   \"cd\_typo\" =
            aggregate(\'selection\_typo\_87687197\_99bd\_4303\_b5c6\_5237003805a6\',\'array\_agg\',\"cd\_typo\")\[0\]
            and \"lb\_hab\_fr\" is not null

            -   attention, le nom de la couche
                « selection\_typo\_87687197\_99bd\_4303\_b5c6\_5237003805a6 »
                est différent d'un projet à l'autre. Pour récupérer le
                bon nom, cliquer sur l'éditeur de
                formule![](./qfield_doc_img/img/100000010000002400000028F74BC86B.png){width="0.2618in"
                height="0.1953in"}, effacer cette valeur de la formule,
                dérouler « couche » et double cliquer sur
                « select\_typo »

![](./qfield_doc_img/img/10000001000006B40000032596776291.png){width="6.6929in"
height="3.1398in"}

### Initialisation des données

Ajouter une entité dans la table « select\_typo » avec l'identifiant
« 1 » laisser cd\_typo null ou avec n'importe quelle valeur si vous
voulez définir une typologie d'habitat par défaut.

La table « t\_habitat » doit obligatoirement avoir une valeur. Cette
contrainte est du au fait que la table n'est pas géométrique et que dans
ce cas, il n'est pas possible d'ajouter une données dans une table vide
avec QField\...

### Qfield - Principe de foncitonnement

Après avoir poussé le projet et l'avoir récupéré sur smartphone il
faut :

-   définir la typologie que l'on souhaite utiliser

    -   Pour cela, appuyer sur les trois barres horizontales en haut à
        gauche pour lister les couches
    -   Faire un appuis long sur la couche select\_typo puis « Afficher
        la liste des entités »
    -   Appuyer sur l'élément «1 »
    -   Activer l'édition
    -   Choisissez la typologie
    -   Valider la modification

-   Editer un habitat

    -   Depuis la liste des couches, faire un appuis long sur la couche
        « t\_habitat » puis « Afficher la liste des entités »
    -   Appuyer sur l'habitat
    -   Activer l'édition,
    -   choisissez l'habitat pour le champ cd\_hab (attention,
        l'affichage de la liste peut être un peu long)
    -   Valider les modifications

Concrètement, le formulaire de « t\_habitat » devrait être inclut dans
le formulaire de la station (t\_station) ce qui le rendrait accessible
dès la numérisation d'uin polygone.
