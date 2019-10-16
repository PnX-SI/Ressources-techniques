===================
Sauvegarder une BDD
===================

Se connecter avec l'utilisateur ``postgres`` :
::

  sudo su postgres

Lancer la sauvegarde d'une BDD (dans notre cas ``importdb`` en SQL, avec commandes inserts) : 
::

  pg_dump -h localhost -U "monpguser" -Fp --inserts --verbose -f /tmp/nomdufichier.sql importdb

Autres ressources : 

- https://geotrek.readthedocs.io/en/master/maintenance.html
