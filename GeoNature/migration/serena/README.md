## Scripts de migration Serena-2 vers GeoNature v2 ##


__IMPORTANT :__

L'ensemble des scripts présentés ici ont été produits dans un certain contexte d'utilisation de Serena et en vue d'un changement d'outil au profit de GeoNature v2.

Il est donc INDISPENSABLE de les éxécuter manuellement et après avoir pris soin de faire les adaptations nécessaires pour qu'ils correspondent à votre BDD de départ et aux données qu'elle contient.
En particulier pour ce qui concerne :

* la création et l'attribution de métadonnées (cadres d'acquisitions, jeux de données, sources)
* la portabilité du référentiels d'utilisateurs (observateurs, déterminateur, valiateur et organismes rattachés)
* les correspondances de nomenclatures et de vocabulaires spécifiques à certains attributs.
* la gestion des géométries (format non-spatial et non-standard dans Serena), de leur types (point, polylignes, polygones) et de leur nature (précise, portée par un site, une commune, une maille etc.)

_Note :_ Avec ces adaptations dépendantes de votre contexte d'utilisation de Serena (pseudo-champ, gestion des utilisateurs, des géométries etc.) et la mise en place de triggers, il est possible de conserver Serena comme une source de données vivante qui alimente la synthèse de GeoNature.
Ce cas n'est pas documenté ici mais il l'est pour ObsOcc -> GeoNature par [@amandine-sahl](@amandine-sahl) ici : [Import générique](https://github.com/PnX-SI/Ressources-techniques/tree/master/GeoNature/migration/generic)

-----------------------
### Procédure : ###

1. Les scripts sont à exécuter dans l'ordre de numérotation des fichiers,
2. Les préfixes _serenadb__ et _gn2db__ indiquent si les scripts doivent être joués dans la BDD de Serena ou de GeoNature,
3. Un script pour faire correspondre et/ou peupler le référentiel d'utilisateurs de GeoNature avec celui de Serena reste à produire --> Non traité pour notre cas car référentiel de départ et gestion des utilisateurs à revoir,
4. Les script 6.x sont optionnels et donne un exemple d'intégration de référentiels géographiques dans GeoNature (zonages espaces naturels INPN).

_Note :_ Prenez soin de lire les commentaires qui jalonnent les différents scripts. 
Certains blocs de SQL contiennent des requêtes de type SELECT qui peuvent servir à étudier et/ou contrôler des tables et des relations avant une opération plus impactante (INSERT, UPDATE, DELETE).

