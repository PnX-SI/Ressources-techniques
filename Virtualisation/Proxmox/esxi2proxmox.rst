MIGRATION ESXI TO PROXMOX
=========================

Ce document traite d'une migration de machines virtuelles installées sous VMware ESXi 5.5 vers Proxmox 5.3.

Nous disposions initialement de 2 serveurs dédiés hébergés, virtualisés avec VMware ESXi. Nous avons décidé de les migrer sur un serveur dédié hébergé, virtualisé avec Proxmox.

Les machines virtuelles sont toutes des serveurs linux Ubuntu (12.04 et 14.04) ou Debian (7, 8 et 9).

Le système de fichiers de l'hyperviseur Proxmox est ZFS.

Procédure de migration
----------------------

**Dans Vsphere**

* arrêter la VM 
* supprimer les éventuels snapshots
* noter les paramètres de la VM (taille CPU, RAM et disque)

**Dans le manager de l'hébergeur**

* migrer l’IP failover sur le serveur Proxmox, 
* noter ou copier coller l’adresse mac virtuelle

**En console SSH** : migrer les 2 fichiers vmdk vers l'hyperviseur Proxmox

Soit depuis l’hôte ESXi :
::
    scp vmname.vmdk root@123.456.789.10:/var/lib/vz/dump/
    scp vmname-flat.vmdk root@123.456.789.10:/var/lib/vz/dump/

Soit depuis l’hyperviseur Proxmox :
::
    cd /var/lib/vz/dump
    scp root@10.987.654.321:/vmfs/volumes/datastore1/vmname/vmname.vmdk vmname.vmdk
    scp root@10.987.654.321:/vmfs/volumes/datastore1/vmname/vmname-flat.vmdk vmname-flat.vmdk


**Dans l’interface Proxmox** : créer une nouvelle VM avec les mêmes paramètres que la VM ESXi (CPU, RAM, disque).

*Pour des VM récentes (Debian > 8)*

* noter l’id = vmid (par ex 104)
* choisir « no media » pour l’onglet « OS »
* créer un disque dur **scsi0**

  - stockage = local (type Directory) 
  - format = qcow2 
  - cache = « write back»
  - discard = cocher (= TRIM = vider les blocks qui ne sont plus alloués ; zfs sait utiliser cet espaces pour d’autres usages (vm, ct, etc.)
* créer la carte réseau en virtio avec pour adresse mac, la mac virtuelle correspondant à l’IP de la VM
* ne pas démarrer la VM

*Si la VM est ancienne (Debian 7 par ex) il faut procéder ainsi*

* créer un disque dur de type **ide0**
* ne pas créer de carte réseau à ce stade

**Sur l’hyperviseur Proxmox, en console**, convertir le fichier vmdk en qcow2 :
::
    cd /var/lib/vz/dump
    qemu-img convert -O qcow2 vmname.vmdk ../images/vmid/vmname.qcow2
    ls -hl # on voit la nouvelle taille du disque en qcow2 (avant TRIM, voir ci-dessous)
    cd /var/lib/vz/images/vmid/
    rm vm-vmid-disk-0.qcow2 # supprimer le disque vide référencé par la VM
    mv vmname.qcow2 vm-vmid-disk-0.qcow2 # le remplacer par le disque fraichement converti

:Note:

    Proxmox peux faire tourner des VM avec des disques au format vmdk. Cette option se justifie s'il est envisagé de revenir sous ESXi ou si les deux solutions de virtualisation sont utilisées simultanément. Dans ce cas, la conversion doit tout de même être faite : ``qemu-img convert -O vmdk vmname.vmdk ../images/vmid/vmname.vmdk``. *A tester*

*Pour les anciennes VM uniquement*

* Options → ordre de boot → ide0 en premier

**Dans l'interface Proxmox, DEMARRER LA VM** (en croisant les doigts)

*Pour les anciennes VM uniquement*

* Matériel → ajouter → carte réseau  →  E1000 (configurer l’adresse MAC correspondant à l’IP)
* redémarrer la VM

**En console** (console proxmox) se connecter dans la VM directement en root

* On va vider tous les blocks non alloués (=commande fstrim) :
  ::
    fstrim -av #machine récente
    fstrim -v / # si l'option -a n'est pas reconnue

* On revoit la conf réseau :
  ::
    nano /etc/network/interfaces # mettre la gateway du nouvel hyperviseur (et sa nouvelle IP si elle a changé)
    reboot # redémarrer la VM

* Tester si la VM ping + tester les ports ouverts : SSH, Apache, PGadmin...

Si tout s’est bien passé, on peut faire un peu de ménage (espace disque notamment)

**Sur l’hyperviseur Proxmox, en console SSH** :
::
    cd /var/lib/vz/dump
    ls -hl  # on voit si tout est supprimable
    rm *.* # à vos risques et périls


**Dans l'interface Proxmox** : déplacer le disque vers un stokage ZFS (local-zfs)

:Note:

    **Pourquoi déplacer le disque en « zvol » (volume ZFS) ?** 
    ZFS est un système de fichiers « copy on write ». qcow2 (qemu copy on write) est aussi un systéme de fichiers « copy on write ». Et empiler l’un sur l’autre n’est pas une bonne pratique, voire risqué. Voir https://forum.proxmox.com/threads/no-qcow2-on-zfs.37518/.

* arrêter la VM
* matériel → disque → déplacer le disque :

  - choisir local-zfs
  - supprimer la source
* redémarrer la vm une fois le déplacement effectué

Après cela la VM n’est plus montée dans le système de fichier classique de l’hyperviseur. On ne peut plus manipuler les fichiers des disques dans ``/var/lib/vz/images/vmid``

Pour voir l’espace utilisé par le disque de la VM, rechercher le disque dans la liste produite par la commande :
::
    zfs list

Pour voir l’état du zpool :
::
    zpool list


Bilan et retour d’expérience
----------------------------

Après migration, l’hyperviseur Proxmox abrite :

* 13 VM actives (nouvelles ou importées depuis ESXI),
* 4 VM arrêtées (archives ou test)
* 2 templates de VM (vierge), 
* 2 templates de conteneurs LXC,
* 3 conteneurs LXC actifs. 

Tout ce petit monde représente un peu plus de 2500 Go d'espace disque alloué alors que seuls 1770 Go sont disponibles sur les disques... 

Grace à ZFS, seuls 550 Go sont utilisés et "vus" par Proxmox. ZFS permet donc de faire de l'over provisioning.

:Note:

    Quelques nettoyages (TRIM sur les VM importées et celles de test) + la migration en « zvol » ont permis de libérer beaucoup d'espace disque non alloué. Cependant, si la VM réalise de nombreuses opération d'écriture/effacement, ces espaces disques non alloués se reconstituent plus ou moins vite. 
    Les opérations de TRIM sont donc importantes et doivent être planifiées dans le cron de l'utilisateur root; Par exemple : ``0 1 * * * fstrim -a`` pour un trim tous les jours à 1h du matin. Si ces opérations de trim ne sont pas faites régulièrement, ZFS voit les blocks remplis mais non alloués comme des blocks utilisés par le système de fichiers des VM. 
    L'espace utilisé par les VM peut donc rapidement grossir et saturer le système de fichiers ZFS de proxmox en cas d'over provisioning. Ceci peut provoquer des corruptions de données.


**Quelques bonnes pratiques dénichées sur le net ou issues de tests**

Concernant les options des disques SCSI :

* cocher l’option « discard » dans les options du disque pour indiquer à ZFS de faire le TRIM en continu.
* cocher l’option « IOTread » dans les options du disque semble améliorer très légèrement les performances de lecture/écriture. Mais avec le format zvol cela bloque les sauvegardes...
* choisir cache = « write back » est recommandé par Proxmox. Cette option ralentit l'écriture mais accélère la lecture.
