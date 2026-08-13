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

- Certbot utilise le serveur web existant (Nginx)
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

## Préparation du dossier ACME\*

```
sudo mkdir -p /srv/certbot/.well-known/acme-challenge
sudo chown -R $USER:$USER /srv/certbot
```

> [!WARNING]
> Cette solution n'a pas marché au Ecrins.
> Le certbot installé en local sur l'hote tente de faire de challenge ACME sur le port 80, hors celui ci est utilisé par le container nginx, il echoue tout le temps.
> Le docker compose est fourni avec un certbot censé geré le certificat et son renouvellement. Il y a cependant un bug dans le template nginx fourni par le dépot qui fait en permanence un redirection 80 -> 443 ce qui fait échouer le challenge ACME.

Solution : Dans le fichier template nginx (/docker-nginx/templates/default.conf.template) rajouter dans la section `server { listen 80`:

        # avoid the HTTP->HTTPS redirect below eating ACME HTTP-01 challenge requests
        if ($request_uri ~ "^/\.well-known/acme-challenge/") { break; }

  juste après le bloc :

        location /.well-known/acme-challenge/ {
            root /var/www/certbot;
        }

Une autre erreur de syntaxe est à corriger : rajouter un $ devant `{WEB_HTTP_PORT}`


        # prevent access by IP
        if ($http_host !~ "${QFIELDCLOUD_HOST}(:${WEB_HTTP_PORT})?") {
            return 444;
        }

Rebuilder l'image nginx et redémarer son container

        cd <qfieldcloud_path>
        docker compose build nginx
        docker compose up -d nginx

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
sudo certbot certonly --webroot -w /srv/certbot -d <qfieldcloud_domain_name>
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

Récupérer le `CONTAINER ID` ou le `NAME` du container d'nginx avec une de ces 2 commandes :

```
docker compose ps | grep nginx
docker ps --filter "name=nginx"
```

On vérifie si la configuration est bien appliquée l'hôte :

```
docker exec -it <id_or_name_nginx_container> cat /etc/nginx/conf.d/default.conf
docker exec -it <id_or_name_nginx_container> nginx -T | grep acme
```

Puis

```
docker compose build nginx
docker compose up -d nginx
```

## Teste du renouvellement du certificat :

sudo certbot renew --dry-run

## Vérification ACME

```
echo OK > /srv/certbot/.well-known/acme-challenge/test.txt
curl http://<qfieldcloud_domain_name>/.well-known/acme-challenge/test.txt
rm /srv/certbot/.well-known/acme-challenge/test.txt
```

> [!IMPORTANT]
>
> - les modifications Docker Compose ne sont prises en compte qu'après recréation du container
> - restart ne suffit pas si les volumes changent

> [!NOTE]
> Pour la création d'utilisateurs ou autres configurations avancées voir : https://github.com/opengisch/qfieldcloud/blob/master/README.md
