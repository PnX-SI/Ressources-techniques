MIGRATION ESXI TO PROXMOX
=========================

Ce document traite d'une migration de machines virtuelles installées sont ESXI 5.5 vers proxmox 5.3
Les machines virtuelles sont toutes des serveurs linux Ubuntu (12.04 et 14.04) ou Debian (7, 8 et 9)

**Dans Vsphere**
    * arrêter la VM 
    * supprimer les éventuels snapshots
    * noter les paramètres (taille : CPU, RAM, disque)

**Dans le manager OVH**
    * migrer l’IP failover sur le server proxmox, 
    * noter ou copier coller l’adresse mac virtuelle

**En console ssh migrer les 2 fichiers vmdk vers l'hyperviseur proxmox** 

sur l’hôte ESXI :

::

    scp vmname.vmdk root@123.456.789.10:/var/lib/vz/dump/
    scp vmname-flat.vmdk root@123.456.789.10:/var/lib/vz/dump/

ou sur l’hyperviseur proxmox :

::

    cd /var/lib/vz/dump
    scp root@10.987.654.321:/vmfs/volumes/datastore1/vmname/vmname.vmdk vmname.vmdk
    scp root@10.987.654.321:/vmfs/volumes/datastore1/vmname/vmname-flat.vmdk vmname-flat.vmdk

**Dans l’interface proxmox**

Pour des VM récentes (Debian > 8 ) :

    * créer une nouvelle VM avec les mêmes paramètres que la VM esxi
    * noter l’id = vmid (par ex 104)
    * choisir « no media » pour l’onglet « OS »
    * créer un disque dur scsi0
        * stockage = local (type Directory) 
        * format = qcow2 
        * cache = « write back»
        * discard = cocher (= TRIM = vider les blocks qui ne sont plus alloués ; zfs sait utiliser cet espaces pour d’autres usages (vm, ct, etc.)
    * créer la carte réseau en virtio avec pour adresse mac, la mac virtuelle correspondant à l’IP de la VM
    * ne pas démarrer la VM

Si la VM est ancienne (Debian 7 par ex) il faut procéder ainsi :

    * créer une nouvelle VM avec les mêmes paramètres que la VM esxi
    * noter l’id = vmid (par ex 104)
    * choisir « no media » pour l’onglet « OS »
    * créer un disque dur ide0
        * stockage = local(type Directory)
        * format = qcow2 
        * cache = « write back»
        * discard = cocher (= TRIM = vider les blocks qui ne sont plus alloués ; zfs sait utiliser cet espaces pour d’autres usages (vm, ct, etc.)
    * ne pas créer de carte réseau
    * ne pas démarrer la VM

**Sur l’hyperviseur proxmox, en console**
	
    * convertir le fichier vmdk en qcow2 (format proxmox)::
	
	   cd /var/lib/vz/dump
	   qemu-img convert -O qcow2 vmname.vmdk ../images/vmid/vmname.qcow2
	   ls -hl # on voit la nouvelle taille du disque en qcow2 (avant TRIM, voir ci-dessous)
	   cd /var/lib/vz/images/vmid/
	   rm vm-vmid-disk-0.qcow2 # supprimer le disque vide référencé par la VM
	   mv vmname.qcow2 vm-vmid-disk-0.qcow2 # le remplacer par le disque fraichement converti

	Pour les anciennes Vms : 
		Matériel → ajouter → carte réseau  →  E1000 (configurer l’adresse MAC correspondant à l’IP)
		Options → ordre de boot → ide0 en premier

**DEMARRER LA VM** (en croisant les doigts)

**En console** (proxmox ou terminal en ssh) se connecter dans la VM

On va vider tous les blocks non alloués (=commande fstrim)
Se mettre en root 
		su
on libère les blocs disque inutilisés (TRIM)
		dd if=/dev/zero of=/mytempfile # va prendre du temps si la vm est ancienne
		# on supprime le fichier temporaire pour libérer l’espace.
		rm -f /mytempfile
On revoit la conf réseau
 revoir le fichier /etc/network/interfaces pour lui mettre la gateway du nouvel hyperviseur (et sa nouvelle IP si elle a changé)
redémarrer la VM
tester si elle ping + tester les ports ouverts : ssh, apache, pgadmin, …)

Si tout s’est bien passé on peut faire un peu de ménage (espace disque notament)
Sur l’hyperviseur proxmox, en console: 
	cd /var/lib/vz/dump
	ls -hl  #on voit si tout est supprimable
	rm *.*
Dans proxmox :
arrêter la VM
matériel → disque → déplacer le disque :
choisir local-zfs
supprimer la source
redémarrer la vm une fois le déplacement effectué
Après cela la VM n’est plus montée dans le système de fichier classique de l’hyperviseur. On ne peut plus manipuler les fichiers des disques dans /var/lib/vz/images/vmid
Pour voir l’espace utilisé par le disque de la VM, rechercher le disque dans la liste produite par 
	zfs list
Pour voir l’état du zpool
	zpool list

Pourquoi déplacer le disque en « zvol » (volume ZFS) ? 
ZFS est un système de fichiers « copy on write ». qcow2 (qemu copy on write) est aussi un systéme de fichiers « copy on write ». Et empiler l’un sur l’autre n’est pas une bonne pratique, voir risqué. https://forum.proxmox.com/threads/no-qcow2-on-zfs.37518/

Bilan et retour d’expérience :
Après qq imports l’hypersiseur habrite 8 Vms importées depuis ESXI, 1 template de VM (vierge), une VM de test et 5 conteneurs LXC dont 2 en template (vierge). Tout ce petit monde occupait environ 900Go sur le disque.
Quelques nettoyage (TRIM sur les VM importées et celle de test) + la migration en « zvol » ont permis de passer l’ensemble à 275 Go dont 260 Go alloué … Les opérations de TRIM sont donc très « rentables ».
Un conteneur Debian 9 de 20 Go fraichement installé occupe moins de 500Mo.

Quelques bonnes pratiques «dénichées sur le net ou issues de tests :
cocher l’option « discard » dans les options du disque pour indiquer à ZFS de faire le TRIM en continu.
cocher l’option « IOTread » dans les options du disque semble améliorer très légèrement les performances de lecture/écriture. Mais avec le format zvol cela bloque les sauvegardes...
choisir cache = « write back » est recommandé par proxmox