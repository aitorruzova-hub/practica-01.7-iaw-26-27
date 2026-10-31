#!/bin/bash
set -ex

#Importamos el archivo .env
source .env

#Eliminamos descargas previas de wp-cli.phar
rm -rf /tmp/wp-cli.*

#Descargamos wpcli
wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -P /tmp/

#Asignamos permisos de ejecucion a wp-cli.phar
chmod +x /tmp/wp-cli.phar

#Movemos wp-cli.phar a /usr/local/bin/wp para que sea accesible globalmente
mv /tmp/wp-cli.phar /usr/local/bin/wp

#Eliminamos instalaciones previas de Wordpress si existen
rm -rf /var/www/html/*

#Descargamos el codigo fuente
wp core download \
  --path=/var/www/html \
  --allow-root

  #Creamos la base de datos y el usuario de WordPress
mysql -u root -e "DROP DATABASE IF EXISTS $WORDPRESS_DB_NAME"
mysql -u root -e "CREATE DATABASE $WORDPRESS_DB_NAME"
mysql -u root -e "DROP USER IF EXISTS $WORDPRESS_DB_USER@$IP_CLIENTE_MYSQL"
mysql -u root -e "CREATE USER $WORDPRESS_DB_USER@$IP_CLIENTE_MYSQL IDENTIFIED BY '$WORDPRESS_DB_PASSWORD'"
mysql -u root -e "GRANT ALL PRIVILEGES ON $WORDPRESS_DB_NAME.* TO $WORDPRESS_DB_USER@$IP_CLIENTE_MYSQL"

#Creamos el archivo de configuracion wp-config.php
wp config create \
  --dbname=$WORDPRESS_DB_NAME \
  --dbuser=$WORDPRESS_DB_USER \
  --dbpass=$WORDPRESS_DB_PASSWORD \
  --dbhost=$WORDPRESS_DB_HOST \
  --path=/var/www/html \
  --allow-root

#Instalamos wordpress
wp core install \
  --url=$LETS_ENCRYPT_DOMAIN \
  --title="$WORDPRESS_TITLE" \
  --admin_user=$WORDPRESS_ADMIN_USER \
  --admin_password=$WORDPRESS_ADMIN_PASSWORD \
  --admin_email=$WORDPRESS_ADMIN_EMAIL \
  --path=/var/www/html \
  --allow-root
  
#Configuramos los enlaces permanentes
  wp rewrite structure '/%postname%/' \
  --path=/var/www/html \
  --allow-root

#Instalamos el plugin de wps-hide-login
wp plugin install wps-hide-login --activate --path=/var/www/html --allow-root

#Configuramos la URL de inicio de sesion personalizada
wp option update whl_page "$WORDPRESS_LOGIN_URL" --path=/var/www/html --allow-root

#Instalar un theme
wp theme install saaslauncher --activate --path=/var/www/html --allow-root

#Instalar un plugin



#Modificamos los permisos
chown -R www-data:www-data /var/www/html

