INSTALLATION DU STOR2
=====================
Intel Xeon-D 1541 - RAM 32GB LEG - 4x HDD SATA 12TB Enterprise Class + 2x SSD SATA 240GB Enterprise Class Soft RAID

**Penser à désactiver le monitoring sur le serveur** sinon il génère une alerte et OVH envoie une équipe. Durant le temps d'intervention tout est bloqué...

Installation du gabarit OVH "Proxmox 6" (sans ZFS). Langue "FR" - installation sur les 2 disques SSD - Cocher "Modifier le partitionnement"

Partitionnement :

    1   primary EXT4    /                       RAID1       20.5 Go (20480 Mo)
    2   primary swap    -                       -           2*4.1 Go (4096 Mo)
    3   lv      EXT4    /var/lib/vz data        RAID1       192.2Go (192158 Mo)
    4   lv      EXT4    /zfslog     ZIL         RAID1       8.2Go (8196 Mo)
    5   lv      EXT4    /zfscache   L2ARC       RAID1       32.8Go (32768 Mo)

Après installation, un "df -h" montre qu'à priori les partitions dédiées au cache et au log ont bien été détectée et utilisées par Proxmox :

    Filesystem             Size  Used Avail Use% Mounted on
    udev                    16G     0   16G   0% /dev
    tmpfs                  3.2G  9.3M  3.2G   1% /run
    /dev/md2                20G  3.3G   16G  18% /
    tmpfs                   16G   25M   16G   1% /dev/shm
    tmpfs                  5.0M     0  5.0M   0% /run/lock
    tmpfs                   16G     0   16G   0% /sys/fs/cgroup
    /dev/mapper/pve-ZIL    7.8G   18M  7.4G   1% /zfslog
    /dev/mapper/pve-L2ARC   32G   48M   30G   1% /zfscache
    /dev/sdb1              510M  156K  510M   1% /boot/efi
    /dev/mapper/pve-data   153G   60M  145G   1% /var/lib/vz
    /dev/fuse               30M   16K   30M   1% /etc/pve
    tmpfs                  3.2G     0  3.2G   0% /run/user/0

Configuration réseau
--------------------
https://docs.ovh.com/fr/dedicated/configurer-plusieurs-serveurs-dedies-dans-le-vrack/#debian-9

Identifier l'interface réseau secondaire (une qui est DOWN. **Ne surtout pas utiliser l'interface qui est en bridge avec vmbr0 de Proxmox**)

    ip a

Modifier la conf réseau

    nano /etc/network/interfaces

Ajouter ceci (adapter le nom de l'interface. Ici eno4)

    auto eno4
    iface eno4 inet static
    address 192.168.0.1
    netmask 255.255.0.0

Rebboter le serveur

Renommer le noeud
-----------------
https://pve.proxmox.com/wiki/Renaming_a_PVE_node

Remplacer le nom du serveur OVH "nsxxxxxxx" par "pvestor2"
    
    nano /etc/hosts

Changer le nom du noeud sur la ou les lignes existantes et ajouter une ligne pour la conf réseau pour le Vrack:

    192.168.0.2     pvestor2    pvestor2

Changer le nom du noeud partout où il apparaît dans les fichiers suivants :

    nano /etc/hostname
    nano /etc/mailname
    nano /etc/postfix/main.cf
    
Si le noeud était en cluster

    nano /etc/pve/corosync.conf

Rebboter le serveur

Installation des paquets ZFS
----------------------------
A priori dans proxmox 6 ces paquets sont présents par défaut.

    apt install zfsutils zfs-initramfs
    reboot   

Suppression des partitions présentes sur les disques SATA
---------------------------------------------------------
https://blog.quindorian.org/2019/08/how-to-install-proxmox-and-setup-a-zfs-pool.html/

On regarde les disques existants

    cd /dev/disk/by-id
    ls

On voit bien les 4 disques SSD et les 4 autres disques
On liste les disques et les partitions des 4 disques qui nous intéressent

    ls -l ata-H* 

ZFS a besoin de disposer de tout le disque, sans partition. 
On va supprimer la ou les partitions existantes (s'il y en a) sur chacun des 4 disques.

    gdisk ata-HGST_HUH721212ALE601_8DH70B2H
        
* p = lister les partitions
* d = delete la partition existante
* w = write les modif
* Y = confirmation

idem pour les 3 autres disques en changeant son id

Création du zpool avec les 4 disques de 12To chacun
---------------------------------------------------
On peut maintenant créer le zpool en raidz-1 (équivalent RAID5 avec une parité) avec les 4 disques (= 2 secondes !)

    zpool create rpool -o ashift=12 raidz1 /dev/disk/by-id/ata-HGST_HUH721212ALE601_8DH70B2H /dev/disk/by-id/ata-HGST_HUH721212ALE601_8DH6ZPGH /dev/disk/by-id/ata-HGST_HUH721212ALE601_8DH70YYH /dev/disk/by-id/ata-HGST_HUH721212ALE601_8DH84M5H

On regarde le statut du zpool

    zpool status

On active la compression

    zfs set compression=lz4 rpool

Création du stockage (en interface)
Datacenter -> Stockage -> Ajouter (choisir ZFS) :

    * ID = local-zfs (important doit avoir le même nom que le stockage sur l'autre noeud pour un bon fonctionnement de la réplication)
    * Pool ZFS = rpool
    * Contenu = Image disque, Conteneur
    * Noeuds = pvestor2
    * Activer = cocher
    * Allocation granulaire = cocher
    * Taille des blocs = 8k


INSTALLATION DU INFRA3
======================
AMD Epyc 7371 - 16c/ 32t - 3.1GHz/ 3.8GHz – 128 Go RAM DDR4 – 2*1920 Go NVMe Soft RAID

**Penser à désactiver le monitoring sur le serveur** sinon il génère une alerte et OVH envoie une équipe. Durant le temps d'intervention tout est bloqué...

Installation du gabarit OVH "Proxmox 5 ZFS". Langue "FR" - installation sur les 2 disques NVMe - Cocher "Modifier le partitionnement"

On modifie jsute la taille du swap.

Partitionnement :

    1   primary ZFS    /                       RAID1        2.1 Go
    2   primary swap    -                       -           2*4.1 Go (4096 Mo)

Inutile de créer des partitions car ZFS va prendre l'ensemble des 2 disques pour les mettre en RAID1 (mirror) et en faire un zpool nommé "rpool". Le système y sera installé dans /rpool/ROOT, les VM et CT dans "/rpool/data" et le swap dans "/rpool/swap".

Configuration réseau
--------------------
https://docs.ovh.com/fr/dedicated/configurer-plusieurs-serveurs-dedies-dans-le-vrack/#debian-9

Identifier l'interface réseau secondaire (une qui est DOWN. **Ne surtout pas utiliser l'interface qui est en bridge avec vmbr0 de Proxmox**)

    ip a

Modifier la conf réseau

    nano /etc/network/interfaces

Ajouter ceci (adapter le nom de l'interface. Ici enp97s0f1)

    auto enp97s0f1
    iface enp97s0f1 inet static
    address 192.168.0.1
    netmask 255.255.0.0

Rebboter le serveur

Renommer le noeud
-----------------
https://pve.proxmox.com/wiki/Renaming_a_PVE_node

Remplacer le nom du serveur OVH "nsxxxxxxx" par "pvemaster"
    
    nano /etc/hosts

Changer le nom du noeud sur la ou les lignes existantes et ajouter une ligne pour la conf réseau pour le Vrack:

    192.168.0.1     pvemaster    pvemaster

Changer le nom du noeud partout où il apparaît dans les fichiers suivants :

    nano /etc/hostname
    nano /etc/mailname
    nano /etc/postfix/main.cf
    
Si le noeud était en cluster

    nano /etc/pve/corosync.conf

Mise à jour vers proxmox 6
--------------------------
Suivre la procédure proxmox : https://pve.proxmox.com/wiki/Upgrade_from_5.x_to_6.0

    reboot

Durant le reboot le système bloc et demande un import manuel du pool rpool. Il faut se loguer en IPMI dans le manager OVH et exécuter les commandes

    zpool import -N rpool
    zpool import -f rpool
    zpool export rpool
    zpool import rpool
    exit

Le serveur devrait redémarrer normalement.


CREATION D'UN PARTAGE NFS ENTRE LES 2 HYPERVISEURS SUR LE VRACK OVH
===================================================================

Sur le serveur STOR2 (celui qui sert le partage NFS) on installe les paquets NFS et un crée un dataset nommé 'backups' dans le zpool principal nommé 'rpool'. Le serveur STOR2 est dans un Vrack (réseau privé) avec des IP du genre 192.168.x.x. Son IP est 192.168.0.2 et celle du 2ème serveur (client du partage NFS) est en 192.168.0.1. On protège l'accès NFS en ouvrant uniquement aux IP comprises en 192.168.0.1 et 192.168.0.255 = 192.168.0.0/24

Création d'un dataset dans le zpool nommé "rpool" (situé sur les 4 disques SATA du STOR2)
-------------------------------------------------

    zpool create rpool/backups

Installation et configuration NFS
---------------------------------

Sur le serveur qui porte le partage NFS :

    apt-get install -y nfs-kernel-server
    zfs set sharenfs="rw=@192.168.0.0/24" rpool/backups
    chmod -r 777 /rpool/backups
    cd /rpool/backups
    touch toto.txt

Pour une autorisation perenne, editer le fichier /etc/exports

    <repertoire_à_partager> <IP_du_clien>(rw,all_squash,anonuid=1000,anongid=1000,sync)
    
  
Sur le serveur client du partage NFS on monte le partage NFS

    cd /mnt/pve
    mkdir STOR2-backup
    mount -t nfs 192.168.0.2:/rpool/backups /mnt/pve/STOR2-backup
    cd STOR2-backup
    touch titi.txt
    ls

On voit le fichier 'toto.txt' et 'titi.txt' qui sont sur le partage NFS du STOR2.

Monter de manière permanente le partage NFS dans '/etc/fstab' :
-------------------------------------------------------------
Sur le serveur client (pvemaster) :

    nano /etc/fstab

Et ajouter cette ligne

    192.168.0.2:/rpool/backups  /mnt/pve/STOR2-backup  nfs  auto  0  0

Monter sans redémarrer

    mount -a

Création d'un stockage NFS sur chacun des hyperviseurs
------------------------------------------------------
Dans l'interface Proxmox, on peut maintenant créer un stockage NFS sur chacun des hyperviseurs (obligation de donner un nom différent).

sur le pvestor2 (stor2)
Datacenter --> Stockage --> ajouter --> **Répertoire**

    ID : local-backup
    répertoire : /mnt/backup/ovh
    Contenu : Fichier de sauvegarde VZDump
    Noeuds : pvestor2
    Activer : cocher
    Partager : cocher
    Nombre maximum de sauvegardes : 5

sur le pvemaster (infra3)
Datacenter --> Stockage --> ajouter --> **NFS**

    ID : stor2-backup
    Serveur : 192.168.0.2
    Export : /rpool/backups
    Contenu : Fichier de sauvegarde VZDump
    Noeuds : pvemaster
    Activer : cocher
    Nombre maximum de sauvegardes : 5

MONTER LE BACKUP STORAGE d'OVH
==============================
Après avoir activé le backup storage dans le manager OVH et avoir autorisé l'accès CIFS et NFS pour l'IP de l'hyperviseur, on peut créer un storage Proxmox dans l'interface PVE web de Proxmox. Chez OVH seul le serveur dédié peut accéder à cet espace de backup.

    cd /mnt
    mkdir backupovh
    apt-get install cifs-utils
    nano /etc/fstab

Ajouter cette ligne avec les bons paramềtres pour le user, le pass et l'adresse de l'hôte.

    //myhostaddress/myuser /mnt/backupovh cifs username=myuser,password=mypass,iocharset=utf8,sec=ntlm,vers=1.0  0  0

On peut maintenant ajouter un storage proxmox sur ce backup storage OVH. 

sur le pvemaster (infra3)
Datacenter --> Stockage --> ajouter --> **NFS**

    ID : OVHbackup-infra3
    Serveur : ftpback-rbx6-68.ovh.net
    Export : /export/ftpbackup/nsxxxxxxx.ip-x-y-z.eu
    Contenu : Fichier de sauvegarde VZDump
    Noeuds : pvemaster
    Activer : cocher
    Nombre maximum de sauvegardes : 1

sur le pvestor2 (STOR2)
Datacenter --> Stockage --> ajouter --> **NFS**

    ID : OVHbackup-stor2
    Serveur : ftpback-rbx3-412.ovh.net
    Export : /export/ftpbackup/nsxxxxxxx.ip-x-y-z.eu
    Contenu : Fichier de sauvegarde VZDump
    Noeuds : pvestor2
    Activer : cocher
    Nombre maximum de sauvegardes : 1


MISE EN CLUSTER DES 2 NOEUDS
============================
https://memo-linux.com/proxmox-mise-en-place-dun-cluster-entre-deux-serveurs/ (Merci Freddy !)

Sur le pvemaster (infra3) : 

    ping 192.168.0.2
    pvecm create pne
    pvecm status

Sur le pvestor2 (stor2) : 

    ping 192.168.0.1
    pvecm add 192.168.0.1

Sur le pvemaster (infra3) : 

    pvecm nodes

On vérifie en interface que les 2 noeuds sont bien listés dans le cluster "pne"

Mise en place de la réplication
-------------------------------

La création d'un espace de stockage proxmox commun permettant la réplicationest un pré-requis. 
Pour faire cela, un storage proxmox ZFS doit existé avec le même nom dans chacun des noeuds. Pour créer ce storage proxmox ZFS commun, il faut le faire en une seule fois, en le créant sur les 2 noeuds à la fois et le zpool doit avoir le même nom également. Ici on utilise le pool "/rpool/data".
Datacenter --> Stockage --> ajouter --> ZFS

    ID : local-zfs
    Pool ZFS : rpool/data
    Contenu : image disque et conteneur
    Noeuds : séléctionner les 2 noeuds
    Activer : cocher
    Allocation granulaire : cocher
    taille des blocs : 8k

Dans mon cas l'espace de stockage "local-zfs" existait déjà avec cette configuration. Il a du être créer lors de la mise en cluster des 2 noeuds.


QUELQUES TESTS
==============

STOR2
-----

Sur le pool ZFS du STOR2, donc sur les disques SATA

"compression=lz4" "atime=on"

    zfs create rpool/test
    cd /rpool/test
    dd if=/dev/zero of=tempfile bs=1M count=4096 conv=fdatasync,notrunc # (4.3 GB, 4.0 GiB) copied, 1.79521 s, 2.4 GB/s
    rm tempfile
    dd if=/dev/zero of=tempfile bs=64k count=65536 conv=fdatasync,notrunc # (4.3 GB, 4.0 GiB) copied, 2.72023 s, 1.6 GB/s
    rm tempfile
    dd if=/dev/zero of=tempfile bs=4k count=1048576 conv=fdatasync,notrunc # (4.3 GB, 4.0 GiB) copied, 8.83952 s, 486 MB/s
    rm tempfile
    zfs destroy rpool/test

"compression=lz4" "atime=off"

    zfs set atime=off rpool/test
    dd if=/dev/zero of=tempfile bs=1M count=4096 conv=fdatasync,notrunc # (4.3 GB, 4.0 GiB) copied, 1.77703 s, 2.4 GB/s
    rm tempfile
    dd if=/dev/zero of=tempfile bs=64k count=65536 conv=fdatasync,notrunc # (4.3 GB, 4.0 GiB) copied, 2.72827 s, 1.6 GB/s
    rm tempfile
    dd if=/dev/zero of=tempfile bs=4k count=1048576 conv=fdatasync,notrunc # (4.3 GB, 4.0 GiB) copied, 8.88948 s, 483 MB/s
    rm tempfile
    zfs destroy rpool/test

Sur les disques SSD du STOR2 (ces disques sont en EXT4)

    cd /tmp
    dd if=/dev/zero of=tempfile bs=1M count=4096 conv=fdatasync,notrunc # (4.3 GB, 4.0 GiB) copied, 17.2624 s, 249 MB/s
    rm tempfile
    dd if=/dev/zero of=tempfile bs=64k count=65536 conv=fdatasync,notrunc # (4.3 GB, 4.0 GiB) copied, 16.0334 s, 268 MB/s
    rm tempfile
    dd if=/dev/zero of=tempfile bs=4k count=1048576 conv=fdatasync,notrunc # (4.3 GB, 4.0 GiB) copied, 16.7741 s, 256 MB/s
    rm tempfile

INFRA3
------

Sur les disques NVMe de l'INFRA3

"compression=on" "atime=off"

    zfs create rpool/test
    cd /rpool/test
    dd if=/dev/zero of=tempfile bs=1M count=4096 conv=fdatasync,notrunc # (4,3 GB, 4,0 GiB) copiés, 2,26821 s, 1,9 GB/s
    rm tempfile
    dd if=/dev/zero of=tempfile bs=64k count=65536 conv=fdatasync,notrunc # (4,3 GB, 4,0 GiB) copiés, 3,10152 s, 1,4 GB/s
    rm tempfile
    dd if=/dev/zero of=tempfile bs=4k count=1048576 conv=fdatasync,notrunc # (4,3 GB, 4,0 GiB) copiés, 6,29717 s, 682 MB/s
    rm tempfile

"compression=lz4" "atime=off"

    zfs set compression=lz4 rpool/test
    dd if=/dev/zero of=tempfile bs=1M count=4096 conv=fdatasync,notrunc # (4,3 GB, 4,0 GiB) copiés, 1,96405 s, 2,2 GB/s
    rm tempfile
    dd if=/dev/zero of=tempfile bs=64k count=65536 conv=fdatasync,notrunc # (4,3 GB, 4,0 GiB) copiés, 2,73529 s, 1,6 GB/s
    rm tempfile
    dd if=/dev/zero of=tempfile bs=4k count=1048576 conv=fdatasync,notrunc # (4,3 GB, 4,0 GiB) copiés, 6,30592 s, 681 MB/s
    rm tempfile
    zfs destroy rpool/test

"compression=lz4" "atime=on"

    zfs set atime=on rpool/test
    dd if=/dev/zero of=tempfile bs=1M count=4096 conv=fdatasync,notrunc # (4,3 GB, 4,0 GiB) copiés, 2,10488 s, 2,0 GB/s
    rm tempfile
    dd if=/dev/zero of=tempfile bs=64k count=65536 conv=fdatasync,notrunc # (4,3 GB, 4,0 GiB) copiés, 2,9023 s, 1,5 GB/s
    rm tempfile
    dd if=/dev/zero of=tempfile bs=4k count=1048576 conv=fdatasync,notrunc # (4,3 GB, 4,0 GiB) copiés, 7,65062 s, 561 MB/s
    rm tempfile
    zfs destroy rpool/test
