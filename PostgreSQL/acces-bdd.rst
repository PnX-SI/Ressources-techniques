===================
Accéder à votre BDD
===================

Par défaut un serveur PostgreSQL n'écoute et n'autorise des connexions que du serveur lui-même (localhost).

Si vous souhaitez vous y connecter depuis un autre serveur ou PC, connectez-vous en SSH sur le serveur de la BDD de l'atlas, puis éditez les fichiers de configuration de PostgreSQL.

Pour écouter toutes les IP, éditez le fichier ``postgresql.conf`` :

::

    sudo nano /etc/postgresql/*/main/postgresql.conf

Remplacez ``listen_adress = 'localhost'`` par  ``listen_adress = '*'``. Ne pas oublier de décommenter la ligne (enlever le ``#``).

Pour définir les IP qui peuvent se connecter au serveur PostgreSQL, éditez le fichier ``pg_hba.conf``

::

    sudo nano /etc/postgresql/*/main/pg_hba.conf

Si vous souhaitez définir des IP qui peuvent se connecter à la BDD, sous la ligne ``# IPv4 local connections:``, rajouter :

::

    host    all     all     MON_IP_A_REMPLACER/0        md5  #Pour donner accès à une IP

ou si vous souhaitez y donner accès depuis n'importe quelle IP, rajouter :

::

    host    all     all     0.0.0.0/0        md5

Redémarrez PostgreSQL pour que ces modifications soient prises en compte :

::

    sudo /etc/init.d/postgresql restart

Si votre atlas se connecte à une BDD mère distante qui contient les données sources (GeoNature, SICEN...), vous devez autoriser le serveur de l'atlas à s'y connecter.

Connectez-vous en SSH sur le serveur hébergeant la BDD source, puis éditez la configuration de PostgreSQL :

::

    sudo nano /etc/postgresql/*/main/pg_hba.conf

Rajouter cette ligne à la fin du fichier (en remplacant IP_DE_LA_BDD_ATLAS par son adresse IP) :

::

    host     all            all             IP_DE_LA_BDD_ATLAS/32       md5

Redémarrez PostgreSQL pour que ces modifications soient prises en compte :

::

    sudo /etc/init.d/postgresql restart

Accès SSH
=========

Il est cependant conseillé de ne pas ouvrir l'accès à votre BDD PostgreSQL et de passer par une connexion SSH. 
Voir https://makina-corpus.com/devops/acceder-base-donnees-postgresql-depuis-qgis-pgadmin-securisee

L'accès à une BDD par une connexion SSH est native dans le logiciel DBeaver.

- Onglet "Général". Attention le host est bien 'localhost'

  .. image:: https://github.com/PnX-SI/Ressources-techniques/blob/master/images/dbeaver-ssh-01.png

- Onglet "SSH"

  .. image:: https://github.com/PnX-SI/Ressources-techniques/blob/master/images/dbeaver-ssh-02.png

