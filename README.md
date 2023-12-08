# Practica-01-08-IAW Jose Francisco León López
## En esta práctica vamos a ver como instalar prestashop en nuestra máquina de Amazon:
### Nuestra máquina de amazon debería estar así configurada:
![1](https://github.com/JoseFco04/practica-01-08-IAW/assets/145347148/49defe99-c15d-4c10-8df8-48d8247b58f1)
### Y tendriamos que crearle un grupo de seguridad para esta práctica y añadirlo cuando estemos instalando la instancia. Debería verse así:
![2](https://github.com/JoseFco04/practica-01-08-IAW/assets/145347148/5c3dc2b7-c600-4817-9b6f-f95d5cdf1ce4)
### Ahora para empezar debemos usar el archivo phppsinfo.php que descargamos previamente y añadirlo a nuestra carpeta de archivos php. EL código del archivo esta en el repositorio de esta práctica.

### Lo siguiente que tenemos que hacer es configurar el script del install_lamp que debemos ejecutar antes de hacer la práctica que paso por paso se ve así:
#### Mostramos todos los comandos que se van ejecutando
~~~
set -ex
~~~
#### Actualizamos los repositorios
~~~
apt update
~~~
#### Actualizamos los paquetes
~~~
#apt upgrade -y
~~~
#### Instalamos el servidor web Apache
~~~
sudo apt install apache2 -y
~~~
#### Instalamos el gestor de bases de datos MySQL
~~~
sudo apt install mysql-server -y
~~~
#### Instalamos PHP
~~~
apt install php libapache2-mod-php php-mysql -y
~~~
#### Copiamos el archivo conf de apache 
~~~
cp ../conf/000-default.conf /etc/apache2/sites-available
~~~
#### Reiniciamos el servicio de Apache
~~~
systemctl restart apache2
~~~
#### Copiamos el archivo de php 
~~~
cp ../php/index.php /var/www/html
~~~
#### Modificamos el propietario y el grupo del directorio /var/www/html
~~~
chown -R www-data:www-data /var/www/html
~~~
### Previamente deberiamos haber tenido los archivos de configuración 000-default.conf y el .htaccess configurados en la máquina. El 000default se debería de ver así:
~~~
ServerSignature Off
ServerTokens Prod
<VirtualHost *:80>
  #ServerName www.example.com
  DocumentRoot /var/www/html
  DirectoryIndex index.php index.html

  <Directory "/var/www/html">
    AllowOverride All
  </Directory>

  ErrorLog ${APACHE_LOG_DIR}/error.log
  CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
~~~
### Y el htaccess así:
~~~
# BEGIN WordPress
<IfModule mod_rewrite.c>
RewriteEngine On
RewriteBase /
RewriteRule ^index\.php$ - [L]
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule . /index.php [L]
</IfModule>
# END WordPress
~~~
### También tenemos que crear un script para el letsencrypt para el tema del dominio y las claves de seguridad que ya hemos usado en practicas anteriores. Paso por paso el script es así:
#### Volvemos a mostrar todos los comandos que se van ejecutando
~~~
set -ex
~~~
#### Actualizamos los repositorios
~~~
apt update
~~~
#### Actualizamos los paquetes
~~~
#apt upgrade -y
~~~
#### Importamos el archivo de variables .env
~~~
source .env
~~~
### Instalamos y actualizamos snapd
~~~
snap install core && snap refresh core
~~~
#### Eliminamos cualquier instalación previa de certbot con apt
~~~
apt remove certbot
~~~
#### Instalamos la aplicación certbot
~~~
snap install --classic certbot
~~~
#### Creamos un alias para la aplicación certbot
~~~
ln -fs /snap/bin/certbot /usr/bin/certbot
~~~
#### Ejecutamos el comando certbot
~~~
certbot --apache -m $CB_MAIL --agree-tos --no-eff-email -d $CB_DOMAIN --non-interactive
~~~
### Y lo máas importante de la práctica y lo que realmente cambia de las otras es el deploy del prestashop y el .env que es el archivo con las variables. El deploy paso por paso es así:
#### Volvemos a mostrar todos los comandos que se van ejecutando
~~~
set -ex
~~~
#### Actualizamos los repositorios
~~~
apt update
~~~
#### Actualizamos los paquetes
~~~
#apt upgrade -y
~~~
#### Importamos el archivo de variables .env
~~~
source .env
~~~
#### Creamos la base de datos y el usuario de la base de datos 
~~~
mysql -u root <<< "DROP DATABASE IF EXISTS $PRESTASHOP_DB_NAME"
mysql -u root <<< "CREATE DATABASE $PRESTASHOP_DB_NAME"
mysql -u root <<< "DROP USER IF EXISTS $PRESTASHOP_DB_USER@$PRESTASHOP_DB_SERVER"
mysql -u root <<< "CREATE USER $PRESTASHOP_DB_USER@$PRESTASHOP_DB_SERVER IDENTIFIED BY '$PRESTASHOP_DB_PASSWORD'"
mysql -u root <<< "GRANT ALL PRIVILEGES ON $PRESTASHOP_DB_NAME.* TO $PRESTASHOP_DB_USER@$PRESTASHOP_DB_SERVER"
~~~
#### Eliminamos instalaciones previas del prestashop
~~~
rm -rf /tmp/prestashop*
~~~
#### Descargamos el codigo fuente de prestashop
~~~
wget https://github.com/PrestaShop/PrestaShop/releases/download/8.1.2/prestashop_8.1.2.zip -P /tmp
~~~
#### Instalar unzip
~~~
apt install unzip -y
~~~
#### Borramos las cosas previas al /var/www/html
~~~
rm -rf /var/www/html/* 
~~~
#### Copiamos el archivo de phppsinfo
~~~
cp ../php/phppsinfo.php /var/www/html
~~~
#### Descargar los archivos de dentro del zip descargado anteriormente
~~~
unzip /tmp/prestashop_8.1.2.zip -d /tmp/prestashop
unzip /tmp/prestashop/prestashop.zip -d /var/www/html
~~~
#### Instalamos las extensiones php para poner lo recomendado de la pagina del phppsinfo.php 
~~~
apt install php-bcmath php-curl php-gd php-intl php-mbstring php-xml php-dom  php-zip -y
~~~
#### Corregimos los archivos con el comando set
~~~
sed -i "s/;max_input_vars = 1000/max_input_vars = $max_input_vars/" /etc/php/8.1/apache2/php.ini
sed -i "s/memory_limit = 128/memory_limit = $memory_limit/" /etc/php/8.1/apache2/php.ini
sed -i "s/post_max_size = 8/post_max_size = $post_max_size/" /etc/php/8.1/apache2/php.ini
sed -i "s/upload_max_filesize = 2/upload_max_filesize = $upload_max_filesize/" /etc/php/8.1/apache2/php.ini
~~~
#### Reiniciamos el servicio de apache
~~~
systemctl restart apache2
~~~
#### Copiamos el nuevo archivo .htaccess
~~~
cp ../htaccess/.htaccess /var/www/html
~~~
#### Cambiamos la información de los directorios para que todos puedan escribir
~~~
chown -R www-data:www-data /var/www/html
~~~
#### Instalamos Prestashop
~~~
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
~~~
#### Borrar la carpeta de install por seguridad
~~~
  rm -rf /var/www/html/install
~~~
### Y el archivo .env con las variables necesarias para ejecurtar el deploy es el siguiente:
~~~
# Configuramos las variables
  WORDPRESS_TITLE="Sitio web de IAW Jose"
  WORDPRESS_ADMIN_USER=admin 
  WORDPRESS_ADMIN_PASS=admin 
  WORDPRESS_ADMIN_EMAIL=josefco@iaw.com

  CB_MAIL=josefco@iaw.com
  CB_DOMAIN=practica8prestasho.ddns.net

  TEMA=sydney
  PLUGIN=bbpress
  PlUGIN2=wps-hide-login

  max_input_vars=5000
  memory_limit=256M
  post_max_size=128M
  upload_max_filesize=128M
  
  PRESTASHOP_NAME=Prestashop_01.8
  PRESTASHOP_COUNTRY=ES
  PRESTASHOP_FNAME=Jose
  PRESTASHOP_LNAME=Francisco
  PRESTASHOP_PASSWORD=Jfleon.450
  PRESTASHOP_PREFIX=prestashop
  PRESTASHOP_DB_SERVER=localhost
  LANGUAGE=es
  PRESTASHOP_DB_NAME=prestashop
  PRESTASHOP_DB_USER=josefco
  PRESTASHOP_DB_PASSWORD=Jfleon.450
  PRESTASHOP_DB_HOST=localhost
  IP_CLIENTE_MYSQL=localhost
~~~
### Una vez ejecutado todo accederiamos a nuestro dominio y ya tendriamos prestashop instalado.

