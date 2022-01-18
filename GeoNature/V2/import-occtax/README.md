# Import python dans Occtax

Par Christian Bièche / Cistude Nature (@christianbieche) sur https://github.com/PnX-SI/GeoNature/issues/1502

Ce script Python permet de mettre à jour des données qui ont été importées dans la Synthèse vers Occtax, via l'API de Occtax, 
en suivant la documentation GeoNature.

Les anciennes données de la Synthèse en double sont supprimées automatiquement.

Le script utilise 2 tables spécifiques pour la création des données et le suivi des mises à jour.

Le script créé les données Occtax et Synthèse en traitant environ 40.000 lignes en 2 heures.

Il faut faire attention aux données insérées car des contrôles sont mis en place dans les tables et quand il y a des exceptions cela ne passe très bien. 
Il faut alors supprimer les données insérées et refaire tourner le script.
En particulier, il faut absolument vérifier que les cd_ref utilisés font bien partie des taxons spécifiques de GeoNature.

Il y a des optimisation à faire car on ne peut pas traiter plus de 10.000 lignes à la fois.

Ce script python est utilisé pour créer automatiquement les données Occtax et Synthèse à partir d'enregistrements de la Synthèse déjà existant en base 
(cas des imports niveau 1 indiqué dans la doc GEONATURE) ou en ajout pour de nouveaux imports.

Il utilise 2 tables :

- la table gn_synthese.synthese_ajout contenant les lignes à traiter en ajout ou maj
- la table gn_synthese.synthase_maj qui permet la trace des actions et le contrôle des lignes déjà traitées.

Remarque :

La table ``synthese_ajout`` reprend les mises à jour par défaut des nomenclatures. Comme le script python prend les informations depuis cette table cela permet 
soit automatiquement de garder le défaut soit de mettre les nomenclatures désirées.

Le script python contient des valeurs par défaut pour les connexions, les noms de serveurs à renseigner. Il prend en paramètre le serveur de base de données 
et le serveur des APIs. Il est donc utilisable soit à partir d'un PC en utilisant les valeurs par défaut sur un serveur particulier ou sur les serveurs GeoNature 
en passant les paramètres.

Il est lancé sur nos serveurs à partir d'un script shell.

Les lignes traitées sont volontairement limitées à 10.000 lignes pour éviter des erreurs python probablement due à des time-out sur la base au bout d'une 
heure de traitement.

Il suffit de relancer le script pour traiter les 10.000 lignes suivantes.

Le script affiche des informations sur le traitement et les erreurs éventuelles. Exemple :
- Début à 2022-01-12 16:09:51.902675
- Fin à 2022-01-12 16:40:17.505163
- Lignes traitées : 8387
- Database connection closed.
