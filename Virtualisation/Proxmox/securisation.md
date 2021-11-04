Sécurisation de proxmox
=======================

### 1. Sécurisation ssh

Quelques recommandation: 
* Changer le port ssh par défault
* Désactiver la connexion root par mot de passe

Editer le fichier `/etc/ssh/sshd_config`

    Port <NEW_PORT>
    PermitRootLogin prohibit-password
    
L'autentifcation `root` n'est possible que par clé ssh à mettre dans `~/.ssh/authorized_keys`

### 2. Configuration du firewall

Proxmox intègre un firewall qui permet de limiter les accès aux machines à certaines IPs, via certains protocoles, certains ports etc... Interessant si on veut restreindre l'accès à l'interface web notamment

Le firewall est configurable au niveau du cluster, au niveau d'un noeud et au niveau de chaque VM/conteneur.
Voir cette documentation pour la configuration du firewall : https://blog.waccabac.com/gestion-du-pare-feu-de-proxmox-ve-4/

:warning: Le firewall fonctionne en mode "ajout de permission". Si on active le firewall avec aucune "règle" définit, **plus rien n'est accessible** ! 

Pour activer le firewall au niveau des VM/conteneur, il est également necessaire d'activer le firewall au niveau de la carte réseau (onglet hardware/network)
