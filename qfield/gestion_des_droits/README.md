## Gestion des droits
[Concepts basiques Qfield](https://docs.qfield.org/reference/qfieldcloud/concepts/). https://docs.qfield.org/reference/qfieldcloud/concepts/

Il faut distinguer les droits associés à la gestion du QGisCloud et les droits associés aux utilisateurs d'un projet.
Tout utilisateur est déclaré dans "Core / People".

**Côté QGisCloud**

Un utilisateur peut être associé à un groupe ("Authentication and Authorization / Group"). Le groupe correspondant à un ensemble d'autorisation relatif à la gestion du QGisCloud. 
Par défaut, il n'y en a pas et l'utilisateur admin est déclaré comme superuser.
Dans le cadre des Parcs nationaux, il faudra évaluer la nécessité et créer un groupe pour les administrateurs de chaque parc où de déclarer chaque admin comme superuser.
Globalement, chaque objet QFieldCloud offre les droits suivants :
* can add
* can change
* can delete
* can view

**Côté projet**

Il est possible de définir une organisation ("core / Organization") qui dans le cadre des Parcs nationaux pourrait correspondre à chaque parc (PNPC, PNFor, PNP...)

A l'intérieur de ces organisations, il est possible de définir une ou plusieurs équipes ("core / Team") qui sont eux même peuplés par une liste d'utilisateur.
C'est ensuite au niveau du projet ("core / project") qu'il est possible d'y associer une ou plusieurs équipes.

Toutefois, il est possible de rattacher directement des utilisateurs aux projets.
Pour chaque utilisateur ou equipe rattaché à un projet, il est possible de lui définir son niveau d’autorisation :
* admin : Peut renommer et supprimer le projet. Possède les même droits que le propriétaire du projet
* manager : Peut ajouter ou supprimer des collaborateurs
* editor : Peut éditer des connées
* reporter : Peut seulement ajouter des donnée, pas le droits de modificaiton ou de suppression
* reader : Lecture seule

L’utilisateur ne peut voir que les projets rattachés à son équipe (ou à lui directement) ainsi que les projets déclarés comme public. Dans ce second cas, depuis QFielf mobile, il apparaitra dans l’onglet « Communauté » mais il ne pourra pas faire de modification.
