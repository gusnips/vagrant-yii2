#!/usr/bin/env bash

# ==================== CONFIGURATION =========================

# Domain to use
domain="myapp.proj" 
# Port to use
domain_port="80"
# Domain to use in admin
admin_domain="$domain"
# Port to use in admin
admin_domain_port="2013"
# MySQL password
mysql_username="vagrant" 
# MySQL password
mysql_password="vagrant"
# Database name 
mysql_database="myapp"

# ------ That's it. Stop editing ------

# Ask everything we need to know to setup the box
# If no stdin avaliable, we use the configuration parameters above
if [ -t 0 ]; then
	read -e -p "Domain to use: " -i "$domain" domain
	read -e -p "Port to use: " -i "$domain_port" domain_port
	read -e -p "Domain to use in admin: " -i "$domain" admin_domain
	read -e -p "Port to use in admin: " -i "$admin_domain_port" admin_domain_port
	read -e -p "MySQL username: " -i "$mysql_username" mysql_username
	read -e -p "MySQL password: " -i "$mysql_password" mysql_password
	read -e -p "Database name: " -i "$mysql_database" mysql_database
fi;

folder="/var/www/$domain" 

# ==================== INSTALLATION =========================

# If first run, add new repositories and install everything
if [ ! -t 0 ]; then

	# update everything
	sudo apt-get update 
	
	# ------- PPA's -------
	
	# utility to be able to use apt-add-repository
	sudo apt-get install -y python-software-properties
	# add ppa's
	sudo apt-add-repository -y ppa:ondrej/apache2
	sudo add-apt-repository -y ppa:ondrej/php5
	# update list with new ppa's
	sudo apt-get update
	
	
	# ------- Apache2 -------
	
	sudo apt-get install -y apache2-mpm-worker
	
	# ------- PHP5 -------
	
	sudo apt-get install -y php5-common libapache2-mod-fastcgi php5-fpm php5-apcu php5-gd php5-mcrypt 
	sudo apt-get install -y curl php5-curl  
	sudo apt-get install -y memcached php5-memcache
	
	
	# ------- MySQL -------
	
	echo mysql-server mysql-server/root_password select "$mysql_password" | debconf-set-selections
	echo mysql-server mysql-server/root_password_again select "$mysql_password" | debconf-set-selections
	sudo apt-get install -y mysql-server-5.5 
	sudo apt-get install -y php5-mysqlnd
	
	# ------- UTILS  -------
	
	# ffmpeg
	sudo apt-get install -y libav-tools
	# imagemagick
	sudo apt-get install -y imagemagick php5-imagick
fi


# ==================== SERVER CONFIGURATION =========================
 

# ------- Apache2 -------

# setup hosts file

# frontend site configuration
VHOST=$(cat <<EOF
# Frontend configuration
<VirtualHost $domain:$domain_port>
	DocumentRoot "$folder/frontend/web"
	ServerName $domain
	ServerAlias www.$domain
	<Directory />
		Options All
		AllowOverride All
		Require all granted
	</Directory>
</VirtualHost>

# Backend configuration
<VirtualHost $domain:$admin_domain_port>
	DocumentRoot "$folder/backend/web"
	ServerName $admin_domain
	<Directory />
		Options All
		AllowOverride All
		Require all granted
	</Directory>
</VirtualHost>

EOF
)
echo "${VHOST}" > "/etc/apache2/sites-available/$domain.conf"

# server ports
if ! grep -q "Listen $domain_port" /etc/apache2/ports.conf; then
	echo "Listen $domain_port" >> /etc/apache2/ports.conf
fi

if ! grep -q "Listen $admin_domain_port" /etc/apache2/ports.conf; then
	echo "Listen $admin_domain_port" >> /etc/apache2/ports.conf
fi

# server ports 
if [ ! -f "/etc/apache2/conf-available/$domain.conf" ]; then 
	echo "ServerName localhost" > "/etc/apache2/conf-available/$domain.conf"
fi

# fix to uses sockets on fastcgi, which is php-fpm default configuration
VHOST=$(cat <<EOF
<IfModule mod_fastcgi.c>
	AddHandler php5-fcgi .php
	Action php5-fcgi /php5-fcgi
	Alias /php5-fcgi /usr/lib/cgi-bin/php5-fcgi
	FastCgiExternalServer /usr/lib/cgi-bin/php5-fcgi -socket /var/run/php5-fpm.sock -pass-header Authorization
</Ifmodule>
EOF
)

echo "${VHOST}" > /etc/apache2/mods-enabled/fastcgi.conf

# enable apache required modules
sudo a2enmod rewrite actions fastcgi alias

# tell apache to use sites vhost file and configs
sudo a2ensite "$domain"
sudo a2enconf "$domain"

# ------- PHP5 -------


# ------- MySQL -------

sudo service mysql start

# create user and database
mysql -uroot --password="$mysql_password" -e "CREATE SCHEMA IF NOT EXISTS $mysql_database DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;"
mysql -uroot --password="$mysql_password" -e "GRANT ALL PRIVILEGES ON $mysql_database.* TO '$mysql_username'@'localhost' IDENTIFIED BY '$mysql_password' WITH GRANT OPTION;FLUSH PRIVILEGES;";
mysql -uroot --password="$mysql_password" -e "GRANT ALL PRIVILEGES ON $mysql_database.* TO '$mysql_username'@'%' IDENTIFIED BY '$mysql_password' WITH GRANT OPTION;FLUSH PRIVILEGES;";

# give external access
sed -i 's/bind-address    = 127.0.0.1/bind-address    = 0.0.0.0/g' /etc/mysql/my.cnf;
sed -i 's/skip-external-locking/skip-external-locking \
skip-name-resolve/g' /etc/mysql/my.cnf;


# ==================== APPLICATION =========================

# install composer
if [ ! -f /usr/local/bin/composer ]; then
	sudo curl -sS https://getcomposer.org/installer | php && mv composer.phar /usr/local/bin/composer
fi

# download project
if [ ! -d "$folder" ]; then 
	composer create-project --prefer-dist --stability=dev yiisoft/yii2-app-advanced "$folder"
	# init project
	php $folder/init --env=Development --overwrite=n
	
	# replace config files
	sed -i "s/mysql:host=localhost;dbname=yii2advanced/mysql:host=localhost;dbname=$mysql_database/g" "$folder/common/config/main-local.php";
	sed -i "s/'password' => '',/'password' => '$mysql_password',/g" "$folder/common/config/main-local.php";
	sed -i "s/'username' => 'root',/'username' => '$mysql_username',/g" "$folder/common/config/main-local.php";
fi


# ==================== FINISH IT =========================

# --- restart services using new config ---

sudo service apache2 reload
sudo service mysql reload
sudo service php5-fpm reload

# install migrations 
sudo php $folder/yii migrate up --interactive=0