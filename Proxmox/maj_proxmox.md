Mise à jour proxmox
===================

Pour le passage en V6 voir ceci :  https://pve.proxmox.com/wiki/Upgrade_from_5.x_to_6.0

Vérifier et:ou mettre à jour les sources
----------------------------------------

    nano /etc/apt/sources.list

Modifier pour obtenir ceci 

    deb http://debian.mirrors.ovh.net/debian buster main contrib non-free
    deb-src http://debian.mirrors.ovh.net/debian buster main contrib non-free

    deb http://security.debian.org/debian-security buster/updates main contrib non-free
    deb-src http://security.debian.org/debian-security buster/updates main contrib non-free

    # buster-updates, previously known as 'volatile'
    deb http://debian.mirrors.ovh.net/debian buster-updates main contrib non-free
    deb-src http://debian.mirrors.ovh.net/debian buster-updates main contrib non-free

Utiliser les sources de la communauté Proxmox

    nano /etc/apt/sources.list.d/pve-install-repo.list

Modifier pour obtenir ceci 

    #deb http://download.proxmox.com/debian buster pvetest
    deb http://download.proxmox.com/debian/pve buster pve-no-subscription

Retirer les sources du support Proxmox non accessible sans souscription

    nano /etc/apt/sources.list.d/pve-enterprise.list

Modifier pour obtenir ceci (= commenter la ligne)

    #deb https://enterprise.proxmox.com/debian/pve buster pve-enterprise

Mettre à jour

    apt update
    apt full-upgrade
    apt dist-upgrade

Nécessite un reboot du serveur.