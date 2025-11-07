Etat initial : Docker installé et droits d'accès au groupe docker donné à un utilisateur (ici gtsi) 

# Clonage du dépôt 

```
git clone –recurse-submodules https://github.com/opengisch/QFieldCloud.git 
```
 
# Configuration 

```
cp .env.example .env 
```
Configuration de base du .env : 
```
QFIELDCLOUD_HOST=<nom_serveur> 
ENVIRONMENT=production 
# Cryptage des formulaires
SECRET_KEY=<valeur aléatoire>
# Rajouter à la liste le nom du serveur
DJANGO_ALLOWED_HOSTS="… <nom_serveur>" 
# Remplacer le .local.yml par .prod.yml
COMPOSE_FILE=...
```

# Installation

```
docker compose up -d –build 
docker compose exec app python manage.py migrate 
docker compose exec app python manage.py collectstatic 
```

# Configuration du certificat

Cette configuration est obligatoire pour l'utilisation de l'admin et de l'API en https.

Se placer dans l'arborescence de QFieldCloud puis commenter dans doker-compose.yml la section `mkcert` puis
```
# Arrêt des containers
docker compose down --remove-orphans
# Installation de certbot
apt install certbot
# Chargement des variable d'environnement de QFieldCloud
source .env
# Génération du certificat 
certbot certonly --standalone -d ${QFIELDCLOUD_HOST} 
```
Certbot est un utilitaire qui génère un certificat via letsencrypt et configure dans le même temps le serveur web local. Le certificat est ensuite à copier dans l'arborescence de QFieldCloud afin d'être déployé ensuite sur le serveur web conteneurisé.

```
sudo cp /etc/letsencrypt/live/${QFIELDCLOUD_HOST}/privkey.pem ./conf/nginx/certs/${QFIELDCLOUD_HOST}-key.pem 
sudo cp /etc/letsencrypt/live/${QFIELDCLOUD_HOST}/fullchain.pem ./conf/nginx/certs/${QFIELDCLOUD_HOST}.pem 
```
 
Restart des conteneurs avec `docker compose up –d` 

Le certificat expirant tous les 3 mois, il doit être renouvelé. Cerbot a installé un cron qui assure le renouvellement /etc/cron.d/certbot : 
```
0 */12 * * * root test -x /usr/bin/certbot -a \! -d /run/systemd/system && perl -e 'sleep int(rand(43200))' && certbot -q renew --no-random-sleep-on-renew 
```
2 fois par jour, certbot vérifie la validité du certificat 

Côté QFieldCloud, il faut donc configurer un cron qui assure la copie du certificat déposé sous `/etc/letsencrypt` ver `/<path_qfieldcloud>/conf/nginx/certs`. 

Edition de la crontab en sudo pour éviter les problèmes de droits `sudo crontab -e` 

Ajouter ces 2 lignes : Tous les jours à 2:30, copie du certificat
```
30 2 * * * source /<path_qfieldcloud>/.env && cp /etc/letsencrypt/live/${QFIELDCLOUD_HOST}/privkey.pem ./conf/nginx/certs/${QFIELDCLOUD_HOST}-key.pem 
30 2 * * * source /<path_qfieldcloud>/.env && sudo cp /etc/letsencrypt/live/${QFIELDCLOUD_HOST}/fullchain.pem ./conf/nginx/certs/${QFIELDCLOUD_HOST}.pem 
```

 

 

 

 
