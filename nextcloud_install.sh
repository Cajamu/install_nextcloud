#!/usr/bin/env bash
#
# Installation script nextcloud including (some) dependencies
#
apt -y update
#apt -y upgrade
apt-get -y install apache2 libapache2-mod-php mariadb-server php-xml php-cli php-cgi php-mysql php-mbstring php-gd php-curl php-zip wget unzip php-intl php-bcmath php-gmp php-imagick
systemctl enable apache2
systemctl enable mariadb
systemctl start apache2
systemctl start mariadb
mv /etc/php/7.3/apache2/php.ini /etc/php/7.3/apache2/php.ini_standard
touch /etc/php/7.3/apache2/php.ini
echo "memory_limit = 512M
upload_max_filesize = 500M
post_max_size = 500M
max_execution_time = 300
date.timezone = Europe/Berlin" >> /etc/php/7.3/apache2/php.ini
cd /var/www/html/
wget https://download.nextcloud.com/server/releases/latest.zip
unzip latest.zip
mkdir -p /nextcloud/data
chown -R www-data:www-data /nextcloud/
chmod -R 755 /nextcloud/
chown -R www-data:www-data /var/www/html/nextcloud/
chmod -R 755 /var/www/html/nextcloud/
rm -f latest.zip
echo "<VirtualHost *:80>
     ServerAdmin admin@example.com
     DocumentRoot /var/www/html/nextcloud/
     ServerName nextcloud.example.com

     Alias /nextcloud "/var/www/html/nextcloud/"

     <Directory /var/www/html/nextcloud/>
        Options +FollowSymlinks
        AllowOverride All
        Require all granted
          <IfModule mod_dav.c>
            Dav off
          </IfModule>
        SetEnv HOME /var/www/html/nextcloud
        SetEnv HTTP_HOME /var/www/html/nextcloud
     </Directory>

     ErrorLog ${APACHE_LOG_DIR}/error.log
     CustomLog ${APACHE_LOG_DIR}/access.log combined

</VirtualHost>" >> /etc/apache2/sites-available/nextcloud.conf
a2ensite nextcloud.conf
a2enmod rewrite
a2enmod headers
a2enmod env
a2enmod dir
a2enmod mime
systemctl restart apache2
echo "Generating file /tmp/instructions containing further instructions..."
echo "#MariaDB
CREATE DATABASE nextclouddb;
CREATE USER 'nextclouduser'@'localhost' IDENTIFIED BY 'password';
GRANT ALL ON nextclouddb.* TO 'nextclouduser'@'localhost';
FLUSH PRIVILEGES;
EXIT;

#Nextcloud conf
Connect to YourServerIP/nextcloud
Create admin account
#
#!Change your data folder location! Do not use a folder under /var/www/html!
#
Input your MariaDB data

Finish setup" >> /tmp/instructions

echo "Done."

