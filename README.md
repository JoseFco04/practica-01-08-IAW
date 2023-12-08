# Practica-01-08-IAW Jose Francisco León López
## En esta práctica vamos a ver como instalar prestashop en nuestra máquina de Amazon:
### Nuestra máquina de amazon debería estar así configurada:
![1](https://github.com/JoseFco04/practica-01-08-IAW/assets/145347148/49defe99-c15d-4c10-8df8-48d8247b58f1)
### Y tendriamos que crearle un grupo de seguridad para esta práctica y añadirlo cuando estemos instalando la instancia. Debería verse así:
![2](https://github.com/JoseFco04/practica-01-08-IAW/assets/145347148/5c3dc2b7-c600-4817-9b6f-f95d5cdf1ce4)
### Ahora para empezar debemos usar el archivo phpsinfo.php que descargamos previamente y añadirlo a nuestra carpeta de archivos php. EL código del archivo esta en el repositorio de esta práctica.

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
