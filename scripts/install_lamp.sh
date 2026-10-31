#!/bin/bash
set -ex

#Actualizar repositorios
apt update

#Instalamos apache
sudo apt install apache2 -y

#Copiamos el archivo de configuracion de Apache
cp ../conf/000-default.conf /etc/apache2/sites-available/

#Habilitamos el modulo de escritura de Apache
sudo a2enmod rewrite

#Instalamos PHP
sudo apt install php libapache2-mod-php php-mysql -y

#Reiniciamos el servicio de Apache para aplicar los cambios
systemctl restart apache2

#Copiamos el archivo index.php a la carpeta raiz del servidor web
cp ../php/index.php /var/www/html

#Cambiamos el propietario y el grupo de la carpeta /var/www/html a www-data
sudo chown -R www-data:www-data /var/www/html

#Instalamos el sistema gestor de bases de datos MySQL
sudo apt install mysql-server -y

