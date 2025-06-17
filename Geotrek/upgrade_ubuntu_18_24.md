## Mise à jour d'Ubuntu 18 à 24


Pour ne pas passer la MAJ de GTA lors des mises à jour du serveur  
Sinon on va passer en 2.114.0 et cela va coincer car non compatible avec Ubuntu 18 sur lequel on est encore  
Voir https://geotrek.readthedocs.io/en/2.114.0/installation-and-configuration/upgrade.html

```
sudo apt-mark hold geotrek-admin
```

Backup BDD (and co)  
Voir https://geotrek.readthedocs.io/en/2.114.0/installation-and-configuration/maintenance.html  
On pourrait suivre la doc et faire :

```
sudo -u postgres pg_dump --no-acl --no-owner -Fc geotrekdb > `date +%Y%m%d%H%M`-database.backup
```

Mais finalement on fait plutôt un "pg_dumpall" qui sauvegarde toute la BDD, ses utilisateurs, variables...

```
cd /home/geotrek
sudo -u postgres pg_dumpall > `date +%Y%m%d%H%M`-database.backup
ls -l
```

Voir https://geotrek.readthedocs.io/en/2.114.0/installation-and-configuration/upgrade.html#with-postgresql-on-same-server  
On vérifie la (ou les) version(s) installées sur le serveur. Dans notre cas on a 2.

```
geotrek@geotrek-demo:~$ pg_lsclusters
Ver Cluster Port Status Owner    Data directory              Log file
14  main    5432 online postgres /var/lib/postgresql/14/main /var/log/postgresql/postgresql-14-main.log
15  main    5434 online postgres /var/lib/postgresql/15/main /var/log/postgresql/postgresql-15-main.log
```

On lance les mises à jour et du ménage sur le serveur Ubuntu 18

```
sudo apt-get update 
sudo apt install ppa-purge
sudo ppa-purge ppa:deadsnakes/ppa 
sudo ppa-purge ppa:ubuntugis/ppa 
pg_lsclusters
sudo apt remove postgresql-14
sudo apt remove postgresql-15
sudo apt remove geotrek-admin convertit screamshotter /// On désinstalle Geotrek-admin et ses dépendances principales
ls /opt/geotrek-admin/   /// Mais cela conserve bien sa conf, les médias, etc...
ls /opt/geotrek-admin/var/media/
sudo apt autoremove 
sudo apt update
sudo apt full-upgrade 
sudo apt upgrade 
sudo apt autoremove 
sudo reboot
```

On lance la MAJ d'Ubuntu 18 vers 20

```
sudo do-release-upgrade
## Dans notre cas, on avait remplacé le fichier de conf SSH local par celui fourni par défaut lors de la mise à jour d'Ubuntu, et du coup ça avait repassé le port SSH sur 22
sudo nano /etc/ssh/sshd_config
sudo systemctl restart sshd.service 
exit
sudo apt-get update
sudo apt-get full-upgrade
sudo apt autoremove
```

On lance la MAJ d'Ubuntu 20 vers 22

```
sudo do-release-upgrade 
```

On lance la MAJ d'Ubuntu 22 vers 24

```
sudo apt-get update
sudo apt-get full-upgrade
sudo apt autoremove
sudo do-release-upgrade 
```

Sur un serveur où on avait aussi installé DOCKER pour un GTR qui tournait sur le même serveur, on doit aussi mettre à jour Docker

```
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
# Add the repository to Apt sources:
echo   "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" |   sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
docker -v
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
docker ps
```

On nettoie les source lists du serveur Ubuntu

```
sudo su
cd /etc/apt/sources.list.d
ls
rm *
exit
```

On réinstalle PostgreSQL et PostGIS

```
sudo apt-get install postgresql-server postgis /// NOK
sudo apt-get install postgresql postgis
sudo apt install postgresql-pgrouting
df -h
pg_lsclusters 
sudo pg_dropcluster 15 main
pg_lsclusters 
ls
```

On restaure la BDD Geotrek

```
cp 202505261429-database.backup /tmp
ls /tmp/
sudo su
su - postgres
psql </tmp/202505261429-database.backup 
exit
exit
```

On relance l'installation de Geotrek-admin sur le serveur

```
NODB=true bash -c "$(curl -fsSL https://raw.githubusercontent.com/GeotrekCE/Geotrek-admin/master/tools/install.sh)"
```
