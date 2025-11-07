Situation :
-----------

On a une couche « t\_habitat » qui possède un champ pointant vers une table « habref » qui elle est lié à une table « typoref ».

L'idée est de pouvoir filtrer dans le formulaire habitat le select de l'habitat en fonction d'une typologie d'habitat.

Déclaration des jointures dans QGis
-----------------------------------

Il faut créer une table intermédiaire, ici nommmé « select\_typo » composé d'un champ id et d'un champ cd\_typo.

Dans les **propriétés **du **projet** qgis, aller dans l'onglet « Source de données » et déclarer le relation entre les table :

-   t\_habitat (cd\_hab) -- habref (cd\_hab)
-   habref (cd\_typo) -- typoref (cd\_typo)
-   select\_typo (cd\_typo) -- typoref (cd\_typo)

Paramétrage du formulaire
-------------------------

### Table « select\_typo »

Ouvrir les propriétés de la couche « select\_typo » aller dans l'onglet « Formulaire ».

-   Dans la barre du haut, choisir « Conception par glisser/déplacé »
-   dans « Form Layout » ne conserver que « cd\_typo »
-   Dans les types d'outil associés au champ
    -   Choisir Valeur relationnelle
    -   couche = typoref
    -   colonne clé = cd\_typo
    -   colonne de valeur = lb\_nom\_typo

<img width="1716" height="805" alt="image" src="https://github.com/user-attachments/assets/192a2a93-beca-4b8b-97cd-002780247bd7" />


Validez la configuration du formulaire en cliquant sur « OK »

### Table habitat

Sur le même principe, aller dans le paramétrage du formulaire dans les propriétés de la couche « t\_habitat »

-   sélectionner « Conception par glisser/déplacé »
-   Cliquer sur le champ « cd\_hab »
-   Choisir le type d'outil « Valeur relationnelle »
    -   couche = habref
    -   colonne clé = « cd\_hab »
    -   Colonne de valeurs = « lb\_hab\_fr »
    -   Ajouter une expression de filtre :
        -   \"cd\_typo\" = aggregate(\'selection\_typo\_87687197\_99bd\_4303\_b5c6\_5237003805a6\',\'array\_agg\',\"cd\_typo\")\[0\] and \"lb\_hab\_fr\" is not null
            -   attention, le nom de la couche « selection\_typo\_87687197\_99bd\_4303\_b5c6\_5237003805a6 » est différent d'un projet à l'autre. Pour récupérer le bon nom, cliquer sur l'éditeur de formule![](./qfield_doc_img/img/100000010000002400000028F74BC86B.png){width="0.2618in" height="0.1953in"}, effacer cette valeur de la formule, dérouler « couche » et double cliquer sur « select\_typo »

<img width="1716" height="805" alt="image" src="https://github.com/user-attachments/assets/532e2b6a-1e96-41a3-9aae-5a2d93b81258" />

### Initialisation des données

Ajouter une entité dans la table « select\_typo » avec l'identifiant « 1 » laisser cd\_typo null ou avec n'importe quelle valeur si vous voulez définir une typologie d'habitat par défaut.

La table « t\_habitat » doit obligatoirement avoir une valeur. Cette contrainte est du au fait que la table n'est pas géométrique et que dans ce cas, il n'est pas possible d'ajouter une données dans une table vide avec QField\...

### Qfield - Principe de foncitonnement

Après avoir poussé le projet et l'avoir récupéré sur smartphone il faut :

-   définir la typologie que l'on souhaite utiliser

    -   Pour cela, appuyer sur les trois barres horizontales en haut à gauche pour lister les couches
    -   Faire un appuis long sur la couche select\_typo puis « Afficher la liste des entités »
    -   Appuyer sur l'élément «1 »
    -   Activer l'édition
    -   Choisissez la typologie
    -   Valider la modification

-   Editer un habitat

    -   Depuis la liste des couches, faire un appuis long sur la couche « t\_habitat » puis « Afficher la liste des entités »
    -   Appuyer sur l'habitat
    -   Activer l'édition,
    -   choisissez l'habitat pour le champ cd\_hab (attention, l'affichage de la liste peut être un peu long)
    -   Valider les modifications

Concrètement, le formulaire de « t\_habitat » devrait être inclut dans le formulaire de la station (t\_station) ce qui le rendrait accessible dès la numérisation d'uin polygone.
