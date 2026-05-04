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
docker compose up -d --build
docker compose exec app python manage.py migrate
docker compose exec app python manage.py collectstatic
```

Création d'un super utilisateur pour l'accès à qfield-cloud

```
docker compose run app python manage.py createsuperuser --username super_user --email super@user.com
```
# Différences certificat standalone et webroot

## Standalone

- Certbot lance son propre serveur HTTP temporaire
- Écoute directement sur le port 80
- Ne dépend d’aucun serveur web existant

✔ Avantages
- Simple à comprendre
- Pas besoin de config Nginx

❌ Inconvénients
- Nécessite que le port 80 soit libre
- Incompatible avec Nginx déjà actif
- Peu adapté à Docker
- Peut casser un service en production

## Webroot 

- Certbot utilise ton serveur web existant (Nginx)
- Dépose un fichier dans un dossier spécifique (webroot)
- Nginx sert ce fichier à Let’s Encrypt

✔ Avantages
- Aucun conflit de port
- Fonctionne avec Docker
- Compatible production
- Renouvellement automatique sans interruption

❌ Inconvénients
- Nécessite config Nginx correcte
- Nécessite un volume partagé si Docker
  
# Configuration du certificat en standalone

Cette configuration est obligatoire pour l'utilisation de l'admin et de l'API en https.

Se placer dans l'arborescence de QFieldCloud puis commenter dans `doker-compose.yml` la section `mkcert` puis

```
# Arrêt des containers
cd <path_qfieldcloud>
docker compose down --remove-orphans
# Installation de certbot
sudo apt install certbot
# Chargement des variable d'environnement de QFieldCloud
source .env
# Génération du certificat
certbot certonly --standalone -d ${QFIELDCLOUD_HOST}
```

Remplacer `<path_qfieldcloud>` par le répertoire home de QfieldCloud (ex : /home/qfcadmin/qfieldcloud).

Certbot est un utilitaire qui génère un certificat via letsencrypt et configure dans le même temps le serveur web local. Le certificat est ensuite à copier dans l'arborescence de QFieldCloud afin d'être déployé ensuite sur le serveur web conteneurisé.

```
sudo cp /etc/letsencrypt/live/${QFIELDCLOUD_HOST}/privkey.pem ./conf/nginx/certs/${QFIELDCLOUD_HOST}-key.pem
sudo cp /etc/letsencrypt/live/${QFIELDCLOUD_HOST}/fullchain.pem ./conf/nginx/certs/${QFIELDCLOUD_HOST}.pem
```

Restart des conteneurs avec `docker compose up –d`

Attention : Ce certificat expire tous les 3 mois, il doit être renouvelé. 

# Configuration du certificat en webroot

Cette configuration permet d'automatiser le renouvellement du certificat sans intéruption de service qui sera réalisée via le cron installé par certbot sous /etc/cron.d/certbot :

```
# Test de validité du certificat 2 fois par jour (*/12)
0 */12 * * * root test -x /usr/bin/certbot -a \! -d /run/systemd/system && perl -e 'sleep int(rand(43200))' && certbot -q renew --no-random-sleep-on-renew
```

Se placer dans le dossier home de QFieldCloud.

## Préparation du dossier ACME*

```
sudo mkdir -p /srv/certbot/.well-known/acme-challenge
sudo chown -R $USER:$USER /srv/certbot
```

\* Automatic Certificate Management Environment

## Modification du `docker-compose.yml` :

```
nginx:
 ...
 volumes:
  …
  - /srv/certbot:/var/www/certbot
  - ./docker-nginx/conf.d:/etc/nginx/conf.d
```
`/srv/certbot:/var/www/certbot` associe `/srv/certbot`de l'hôte à `/var/www/certbot` du container nginx, utilisé lors du test de validité du certificat.
`./docker-nginx/conf.d:/etc/nginx/conf.d` associe `./docker-nginx/conf.d` de l'hôte à `/etc/nginx/conf.d` du container nginx, pratique pour avoir un accès direct à la configuration du serveur web.

## Relance de `docker compose`
 
Réaliser cette étape pour prise en compte du docker-compose.yml et la création des volumes :

```
docker compose down
docker compose up -d --force-recreate
```

## Création d'un certificat en webroot

```
# Lister les certificats
sudo certbot certificates
# La suppression n'est pas nécessaire
sudo certbot delete
# Génération d'un 1er certificat de type webroot manuellement
sudo certbot certonly --webroot -w /srv/certbot -d qfieldcloud.vanoise-parcnational.fr
```

## Modification de ./docker-nginx/conf.d/default.conf

Le bloc ci-dessous permet à Nginx de servir les fichiers de validation Let’s Encrypt. Il est adapté pour éviter des erreurs 404

```
location ^~ /.well-known/acme-challenge/ {
    alias /var/www/certbot/.well-known/acme-challenge/;
    default_type "text/plain";
}
```

## Vérification de la bonne répercution de la modification côté container :
On teste si la modification du fichier ./docker-nginx/conf.d/default.conf modifie bien le fichier /etc/nginx/conf.d/default.conf du container :

```
docker exec -it <id_nginx_container> cat /etc/nginx/conf.d/default.conf
```

On vérifie la configuration appliquée à Nginx :

```
docker exec -it <nginx_container> nginx -T | grep acme
```

## Teste du renouvellement du certificat :
sudo certbot renew --dry-run


## Vérification ACME 

```
echo OK > /srv/certbot/.well-known/acme-challenge/test.txt
curl http://qfieldcloud.vanoise-parcnational.fr/.well-known/acme-challenge/test.txt
rm /srv/certbot/.well-known/acme-challenge/test.txt
```

> [!IMPORTANT]
> - les modifications Docker Compose ne sont prises en compte qu'après recréation du container
> - restart ne suffit pas si les volumes changent


Pour la création d'utilisateur ou autres configuration avancé voir : https://github.com/opengisch/qfieldcloud/blob/master/README.md
