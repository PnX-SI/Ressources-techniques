INSTALLATION ET CONFIG DU SERVEUR MAIL
======================================

Par @gildeluermoz - Novembre 2021

Ressources
----------

- https://www.debian.org/releases/jessie/mips/ch08s05.html.fr
- https://wiki.visionduweb.fr/index.php?title=Installer_Exim#Configurer_automatiquement_Exim

Installation d'exim4
--------------------

```
sudo apt install exim4
sudo dpkg-reconfigure exim4-config
```

Choisir
-------

- Distribution directe par SMTP (site Internet)
- geonature.mondomaine.fr
- 127.0.0.1 ; ::1
- geonature.mondomaine.fr
- geonature.mondomaine.fr
- laisser vide
- Non
- Format "mbox" dans /var/mail
- Non

Vérification
------------

```
sudo /etc/init.d/exim4 restart
sudo /etc/init.d/exim4 status
```

Tester
------

```
mail -s "Hello World !" toto@gmail.com < /dev/null
```

L'expéditeur est adminuser@monvps.ovh.net

Redirection des utilisateurs système (permet de changer l'expéditeur du mail)
-----------------------------------------------------------------------------

```
sudo nano /etc/email-addresses
ajouter ceci à la fin du fichier
root : nepasrepondre@geonature.mondomaine.fr
gamadmin : nepasrepondre@geonature.mondomaine.fr
```

```
sudo nano /etc/mailname
geonature.mondomaine.fr
```

Config GeoNature correspondante
-------------------------------

Les 4 premières sont les config par défaut de Flask_mail et ne devraient pas être utiles (à tester)

```
[MAIL_CONFIG]
    MAIL_SERVER = "localhost"
    MAIL_PORT = 25
    MAIL_USE_TLS = false
    MAIL_USE_SSL = false
    MAIL_DEFAULT_SENDER = "nepasrepondre@geonature.mondomaine.fr"
    MAIL_ASCII_ATTACHMENTS = false
    ERROR_MAIL_TO = ["Toiladmin <moi@mondomaine.com>"]
```
