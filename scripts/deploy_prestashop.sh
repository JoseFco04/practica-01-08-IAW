#!/bin/bash

# Muestra todos los comandos que se van ejecutando
set -ex

# Actualizamos los repositorios
apt update

# Actualizamos los paquetes
#apt upgrade -y

# Importamos el archivo de variables .env
source .env

# Creamos la base de datos y el usuario de la base de datos 
mysql -u root <<< "DROP DATABASE IF EXISTS $PRESTASHOP_DB_NAME"
mysql -u root <<< "CREATE DATABASE $PRESTASHOP_DB_NAME"
mysql -u root <<< "DROP USER IF EXISTS $PRESTASHOP_DB_USER@$PRESTASHOP_DB_SERVER"
mysql -u root <<< "CREATE USER $PRESTASHOP_DB_USER@$PRESTASHOP_DB_SERVER IDENTIFIED BY '$PRESTASHOP_DB_PASSWORD'"
mysql -u root <<< "GRANT ALL PRIVILEGES ON $PRESTASHOP_DB_NAME.* TO $PRESTASHOP_DB_USER@$PRESTASHOP_DB_SERVER"


# Eliminamos instalaciones previas del prestashop
rm -rf /tmp/prestashop*

# Descargamos el codigo fuente de prestashop
wget https://github.com/PrestaShop/PrestaShop/releases/download/8.1.2/prestashop_8.1.2.zip -P /tmp

# Instalar unzip
apt install unzip -y

# Borramos las cosas previas al /var/www/html
rm -rf /var/www/html/* 

# Copiamos el archivo de phppsinfo
cp ../php/phppsinfo.php /var/www/html

# Descargar los archivos de dentro del zip descargado anteriormente
unzip /tmp/prestashop_8.1.2.zip -d /tmp/prestashop
unzip /tmp/prestashop/prestashop.zip -d /var/www/html

# Instalamos las extensiones php 
apt install php-bcmath php-curl php-gd php-intl php-mbstring php-xml php-dom  php-zip -y

# Corregimos los archivos con el comando set
sed -i "s/;max_input_vars = 1000/max_input_vars = $max_input_vars/" /etc/php/8.1/apache2/php.ini
sed -i "s/memory_limit = 128/memory_limit = $memory_limit/" /etc/php/8.1/apache2/php.ini
sed -i "s/post_max_size = 8/post_max_size = $post_max_size/" /etc/php/8.1/apache2/php.ini
sed -i "s/upload_max_filesize = 2/upload_max_filesize = $upload_max_filesize/" /etc/php/8.1/apache2/php.ini

# Reiniciamos el servicio de apache
systemctl restart apache2

# Copiamos el nuevo archivo .htaccess
cp ../htaccess/.htaccess /var/www/html

# Cambiamos la información de los directorios para que todos puedan escribir
chown -R www-data:www-data /var/www/html

# Instalamos Prestashop
php /var/www/html/install/index_cli.php \
  --name=$PRESTASHOP_NAME \
  --country=$PRESTASHOP_COUNTRY \
  --firstname=$PRESTASHOP_FNAME \
  --lastname=$PRESTASHOP_LNAME \
  --password=$PRESTASHOP_PASSWORD \
  --prefix=$PRESTASHOP_PREFIX \
  --db_server=$PRESTASHOP_DB_SERVER \
  --db_name=$PRESTASHOP_DB_NAME \
  --db_user=$PRESTASHOP_DB_USER \
  --db_password=$PRESTASHOP_DB_PASSWORD \
  --domain=$CB_DOMAIN \
  --email=$CB_MAIL \
  --language=$LANGUAGE \
  --ssl=1

  # Borrar la carpeta de install por seguridad
  rm -rf /var/www/html/install