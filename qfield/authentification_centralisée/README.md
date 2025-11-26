Authentification centralisée avec Qfield
========================================

L'outils d'administration web de QfieldCloud est codé en python avec le framework Django. Il l'offre la possibilité de se connecter avec des mécanismes d'authentication externe (authentification social type google, facebook, ou avec des outils implémentant l'authentication OAuth). Ce mécanisme s'appuie sur la librairie [Allauth](https://docs.allauth.org/en/latest/). Cette librairie offre la possiblité de customiser les mécanisme d'authentification via l'implémentation [d'adapteurs](https://docs.allauth.org/en/latest/usersessions/adapter.html#adapter).

L'objectif de la mise en place d'un QFieldCLoud mutualisé necessite que tous les agents des parcs puissent se connecter sans qu'on ai à leur créer un compte dans l'outils. Pour l'exercice, nous avons essayer de connecter QFieldCloud à l'application KeyCloak (application d'authtification centralisée capable d'aspirer des AD). La création d'une classe customisé d'Adapteur, permet d'automatiquement attribuer un utiliseur à son organisme préalablement créer dans l'outil. Il aura ainsi directement accès aux projets lié à sa structure.

Pour ajouter un mécanisme d'authentification centralisé, il faut éditer le fichier la variable `SOCIALACCOUNT_PROVIDERS` du fichier .env et y renseigner les paramètre de son outil d'authentification centralisé.

    SOCIALACCOUNT_PROVIDERS = '{
    "openid_connect": {
        "OAUTH_PKCE_ENABLED": true,
        "APP": {
        "provider_id": "keycloak",
        "name": "Keycloak",
        "client_id": "<client-id>",
        "settings": {
            "server_url": "https://keycloak.local/realms/myrealm/.well-known/openid-configuration"
        }
        }
    }
    }'


Le fichier présent dans ce dossier :  `./customo_adapters.py", contient une classe permettant de surcoucher le mécanisme d'authentification par défaut en associant automatiquement un utilisateur à son organisme en se basant sur son adresse mail.

Il faut ensuite indiquer à QFieldCloud d'utiliser cette classe : 

    SOCIALACCOUNT_ADAPTER = "<path_vers_mon_module_custo>.MyCustomSocialAdapter"
