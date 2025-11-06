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

Commenter dans doker-compose.yml la section `mkcert` puis
```
docker compose down --remove-orphans 
apt install certbot 
source .env 
certbot certonly --standalone -d ${QFIELDCLOUD_HOST} 
```
 

sudo cp /etc/letsencrypt/live/${QFIELDCLOUD_HOST}/privkey.pem ./conf/nginx/certs/${QFIELDCLOUD_HOST}-key.pem 

sudo cp /etc/letsencrypt/live/${QFIELDCLOUD_HOST}/fullchain.pem ./conf/nginx/certs/${QFIELDCLOUD_HOST}.pem 

 

docker compose up –d 

 

Le certificat expire tous les 3 mois, il faut donc le renouveler : 

Cerbot install un cron qui assure le renouvellement /etc/cron.d/certbot : 

0 */12 * * * root test -x /usr/bin/certbot -a \! -d /run/systemd/system && perl -e 'sleep int(rand(43200))' && certbot -q renew --no-random-sleep-on-renew 

=> 2 fois par jour, certbot vérifie la validité du certificat 

 

Il est donc nécessaire de créer un cron qui assure la copie du certificat déposé sous /etc/letsencrypt ver /<path_qfieldcloud>/conf/nginx/certs. 

 

sudo crontab -e 

 

Ajouter ces 2 lignes : 

30 2 * * * source /<path_qfieldcloud>/.env && cp /etc/letsencrypt/live/${QFIELDCLOUD_HOST}/privkey.pem ./conf/nginx/certs/${QFIELDCLOUD_HOST}-key.pem 

30 2 * * * source /<path_qfieldcloud>/.env && sudo cp /etc/letsencrypt/live/${QFIELDCLOUD_HOST}/fullchain.pem ./conf/nginx/certs/${QFIELDCLOUD_HOST}.pem 

=> Tous les jours à 2:30, copie du certificat 

 

 

 

 
