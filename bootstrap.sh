#!/bin/bash

# ==================== CONFIGURATION =========================
# Mysql root password
mysql_root_password=$([ -z "$1" ] && echo 'vagrant' || echo "$1")
ip=$([ -z "$2" ] && echo '127.0.0.1' || echo "$2")
domain=$([ -z "$3" ] && echo 'localhost' || echo "$3")

if [ -t 0 ]; then
	read -e -p "MySQL root password: " -i "$mysql_root_password" mysql_root_password
	read -e -p "IP: " -i "$ip" ip
	read -e -p "Domain: " -i "$domain" domain
fi

# ==================== INSTALLATION =========================

# add new repositories and install everything

# update everything if not

sudo apt-get update

# ------- PPA's -------

# utility to be able to use apt-add-repository
sudo apt-get install -y python-software-properties

# we try to avoid running it by checking if the script didn't come from vagrant
if [ ! -t 0 ]; then
	# add ppa's
	sudo apt-add-repository -y ppa:ondrej/apache2
	sudo add-apt-repository -y ppa:ondrej/php5
	# update list with new ppa's
	sudo apt-get update
fi


# ------- Apache2 -------

sudo apt-get install -y apache2-mpm-worker

# ------- PHP5 -------

sudo apt-get install -y php5-common libapache2-mod-fastcgi php5-fpm php5-apcu php5-gd php5-mcrypt
sudo apt-get install -y curl php5-curl
sudo apt-get install -y memcached php5-memcache


# ------- MySQL -------

echo "mysql-server-5.5 mysql-server/root_password password $mysql_root_password
mysql-server-5.5 mysql-server/root_password seen true
mysql-server-5.5 mysql-server/root_password_again password $mysql_root_password
mysql-server-5.5 mysql-server/root_password_again seen true
" | sudo debconf-set-selections

#in case it's already installed, we change the password instead
if [ ! -f /etc/init.d/mysql ]; then
	sudo apt-get install -y mysql-server-5.5
else
	sudo dpkg-reconfigure -f noninteractive mysql-server-5.5
fi

sudo apt-get install -y php5-mysqlnd

# ------- UTILS  -------

# ffmpeg
# sudo apt-get install -y libav-tools ffmpeg
# imagemagick
# sudo apt-get install -y imagemagick php5-imagick


# ==================== SERVER CONFIGURATION =========================


# ------- Apache2 -------

# fix to uses sockets on fastcgi, which is php-fpm default configuration
VHOST=$(cat <<EOF
<IfModule mod_fastcgi.c>
	AddHandler php5-fcgi .php
	Action php5-fcgi /php5-fcgi
	Alias /php5-fcgi /usr/lib/cgi-bin/php5-fcgi
	FastCgiExternalServer /usr/lib/cgi-bin/php5-fcgi -socket /var/run/php5-fpm.sock -pass-header Authorization
	<Directory /usr/lib/cgi-bin/>
		Options All
		Require all granted
        SetHandler php5-fcgi
	</Directory>
</Ifmodule>
EOF
)

if [ ! -f /etc/apache2/mods-enabled/fastcgi.conf ]; then
	echo "${VHOST}" > /etc/apache2/mods-enabled/fastcgi.conf
fi

# enable apache required modules
sudo a2enmod rewrite actions fastcgi alias


# default conf adds server name
if [ ! -f /etc/apache2/conf-available/default.conf ]; then
	echo "ServerName $domain" > /etc/apache2/conf-available/default.conf
fi
sudo a2enconf default

# ------- PHP5 -------

# install composer
if [ ! -f /usr/local/bin/composer ]; then
	sudo curl -sS https://getcomposer.org/installer | php && mv composer.phar /usr/local/bin/composer
else
	sudo composer self-update
fi


# ------- MySQL -------

# give external access
sed -i 's/bind-address    = 127.0.0.1/bind-address    = 0.0.0.0/g' /etc/mysql/my.cnf;
sed -i 's/skip-external-locking/skip-external-locking \
skip-name-resolve/g' /etc/mysql/my.cnf;


# ==================== FINISH IT =========================

# --- restart services using new config ---

sudo service apache2 restart
sudo service mysql restart
sudo service php5-fpm restart


echo 'Done! This is a link to your new server: http://$domain'
echo ''
echo 'You may now enter your new box:'
if [ -z "$3" ]; then
	echo 'docker run -it -v \$(pwd):/var/www -p $ip:80:80 /bin/bash'
else
	echo 'vagrant ssh'
fi
echo ''
echo 'And create a new application: '
echo 'sudo /var/www/bootstrap-advanced.sh'
echo 'or'
echo 'sudo /var/www/bootstrap-basic.sh'
